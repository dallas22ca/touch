class Importer
  
  def initialize(org_id)
    @org = Organization.find org_id
    @url = @org.members_import.url
    @url = @url.split("?").first if @url.include? "?"
    @basename = File.basename(@url)
    @ext = File.extname(@basename)
    @path = @org.members_import.path
  end
  
  def spreadsheet
    @spreadsheet = open_spreadsheet
  end
  
  def import
    warnings = []
    
    if headers
      row_count = spreadsheet.count
    
      (2..spreadsheet.last_row).each do |i|
        progress = (i * 100) / row_count
        data = Hash[[headers, spreadsheet.row(i).map{ |c| c.to_s.strip }].transpose]
        
        member = @org.members.where("data @> 'email=>#{data["email"]}'").first
        member = @org.members.new unless member
        member.bulk_action = true
        member.data ||= {}
        member.data = member.data.merge(data)
        member.save!
        
        @org.update import_progress: "Contact import is #{progress}% complete." if progress % 3 == 0
        warnings.push member.errors.full_messages if member.errors.any?
      end
      
      progress = "Contact import is complete."
      output = { 
        success: true, 
        warnings: warnings
      }
    else
      progress = "The file provided does not have headers. Please re-upload."
      output = { 
        success: false, 
        errors: progress
      }
    end
    
    @org.update importing: false, members_import: nil, import_progress: progress
    
    output
  end
  
  def headers
    name_found = false
    headers = []

    spreadsheet.row(1).each do |title|
      title = title.to_s.strip.parameterize.underscore
      name_found = true if %w[name full_name first_name].include? title
      title = "full_name" if title == "name"
      title = "email" if title == "email_address"
      title = "address" if title == "mailing_address"
      headers.push title
    end
    
    if name_found
      headers
    else
      false
    end
  end

  def open_spreadsheet
    case @ext
    when ".csv" then Roo::CSV.new @path
    when ".xls" then Roo::Excel.new @path
    when ".xlsx" then Roo::Excelx.new @path
    when ".ods" then Roo::OpenOffice.new @path
    else raise "Unknown file type: #{@basename}"
    end
  end
  
end