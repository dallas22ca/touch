class Organization < ActiveRecord::Base
  jibe

  serialize :modules, Array

  has_many :members
  has_many :users, through: :members
  has_many :rooms
  has_many :events
  has_many :segments
  has_many :folders
  has_many :folderships, through: :folders
  has_many :fields
  has_many :messages
  
  has_attached_file :logo, default_url: "default_org_logo"
  validates_attachment_content_type :logo, content_type: /jpeg|jpg|gif|png/
  validates_presence_of :name, :permalink
  
  before_validation :format_permalink
  before_validation :format_website
  
  validates_presence_of :name, :permalink
  validates_uniqueness_of :permalink
  
  before_create :generate_keys
  after_create :add_default_fields
  after_save :add_modules_to_admins, if: :modules_changed?
  
  def generate_keys
    self.publishable_key = loop do
      random_publishable_key = SecureRandom.urlsafe_base64(20, false).gsub(/-|_/, "")
      break random_publishable_key unless Organization.exists?(publishable_key: random_publishable_key)
    end
    
    self.secret_key = loop do
      random_secret_key = SecureRandom.urlsafe_base64(20, false).gsub(/-|_/, "")
      break random_secret_key unless Organization.exists?(secret_key: random_secret_key)
    end
  end
  
  def add_default_fields
    fields.create([
      { name: "First Name", permalink: "first_name" },
      { name: "Last Name", permalink: "last_name" },
      { name: "Email", permalink: "email" }
    ])
  end
  
  def admins
    members.where("roles ilike ?", "%admin%")
  end
  
  def add_modules_to_admins
    admins.each do |m|
      (modules + modules_was).uniq.each do |mod|
        if modules_was.include?(mod) && !modules.include?(mod)
          m.remove_preset mod.to_sym
        else
          m.add_preset mod.to_sym
        end
      end
      
      m.save
    end
    
    reload
    seed_first_folder if modules.include?("folders") && folders.count == 0 && admins.any?
  end
  
  def format_website
    self.website = "http://#{website}" unless website.blank? || website =~ /http/
  end
  
  def format_permalink
    if permalink.blank?
      split = name.downcase.split(" ")
      base = split.length > 1 ? split.map{ |s| s[0] }.join : name.downcase
      
      self.permalink = (1..10000000).each do |n|
        perma = n == 1 ? base : "#{base}-#{n}"
        break perma unless Organization.exists?(permalink: perma)
      end
    end
    
    self.permalink = permalink.parameterize
  end
  
  def to_param
    permalink
  end
  
  def filter_members(filters = [])
    new_query = true
    time = Time.zone.now
    members = self.members
    include_events = false
    member_ids = []
    queries = []
    
    normal_fields = {
      members: ["created_at"],
      events: ["created_at"]
    }
    
    if filters
      filters.each do |filter|
        if filter.has_key?(:field) && filter.has_key?(:matcher)
          
          field = filter[:field].to_s
          matcher = filter[:matcher].to_s
          value = filter[:value].to_s
          event = filter[:event].to_s.downcase
          include_events = true if !event.blank?
          table = !event.blank? ? "events" : "members"
        
          if field == "q"
            queries.push "LOWER(CAST(avals(#{table}.data) AS text)) ilike '%#{value}%'"
          elsif field == "occurances"
            member_ids_to_add = {}
            
            if matcher == "within"
              member_ids_from_events = events.where("events.created_at > ? and verb = ?", value.to_i.seconds.ago, event).group(:member_id).count
            else
              self.member_ids.map { |id| member_ids_to_add[id] = 0 }
              member_ids_from_events = events.where(verb: event).group(:member_id).count
            end
          
            member_ids_from_events.map { |k, v| member_ids_to_add[k] = v }
            
            case matcher
            when "is"
              member_ids_to_add = member_ids_to_add.select { |k, v| v == value.to_i }
            when "is_not"
              member_ids_to_add = member_ids_to_add.select { |k, v| v != value.to_i }
            when "greater_than"
              member_ids_to_add = member_ids_to_add.select { |k, v| v > value.to_i }
            when "less_than"
              member_ids_to_add = member_ids_to_add.select { |k, v| v < value.to_i }
            end
            
            member_ids_to_add = member_ids_to_add.map { |k, v| k }
            
            if new_query
              new_query = false
              member_ids = member_ids_to_add
            else
              member_ids = member_ids & member_ids_to_add
            end
          elsif normal_fields[table.to_sym].include? field
            case matcher
            when "is"
              queries.push "#{table}.#{field} = '#{value}'"
            when "is_not"
              queries.push "#{table}.#{field} != '#{value}'"
            when "like"
              queries.push "#{table}.#{field} ilike '%#{value}%'"
            when "greater_than"
              queries.push "#{table}.#{field} > '#{value}'"
            when "less_than"
              queries.push "#{table}.#{field} < '#{value}'"
            end  
          else
            case matcher
            when "is"
              queries.push "#{table}.data @> hstore('#{field}', '#{value}')"
            when "is_not"
              queries.push "#{table}.data -> '#{field}' <> '#{value}'"
            when "like"
              queries.push "#{table}.data -> '#{field}' ilike '%#{value}%'"
            when "greater_than"
              queries.push "#{table}.data -> '#{field}' > '#{value}'"
            when "less_than"
              queries.push "#{table}.data -> '#{field}' < '#{value}'"
            end
          end
        end
        
      end
    end
    
    members = members.where(id: member_ids) if include_events
    members = members.where(queries.join(" and ")) if queries.any?
    members
  end
  
  def self.available_modules
    Member.presets.reject{ |m, v| m == :admin || m == :contacts }.map{ |k, v| k.to_s }
  end
  
  def seed_first_folder
    admin = admins.first

    if admin
      folder = folders.create name: "Jack & Jill", creator: admin, seed: "buyer"
    
      file = File.open("#{Rails.root}/public/resources/32 Marketing Ideas.pdf")
      doc = folder.documents.create file: file, creator: admin, skip_jibe: true
      file.close
    
      folder.homes.create(
        address: "301 Front St W", 
        city: "Toronto",
        province: "Ontario",
        postal_code: "M5V 2T6",
        beds: 4,
        baths: 3,
        longitude: -79.38703799999996,
        latitude: 43.64251,
        price: 450000,
        creator: admin
      )
    end
  end
end
