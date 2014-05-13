class Homer
  include Capybara::DSL
  
  def initialize(sandbox = false)
    Capybara.current_driver = :webkit
    @sandbox = sandbox
  end
  
  def search(q)
    if @sandbox
      html = File.read "#{Rails.root}/spec/assets/homer/index.html"
    else
      property_id = 14045283
      visit "http://beta.realtor.ca/Index.aspx"
      page.evaluate_script "$('#home_search_input').val('21b mackenzie street dartmouth');"
      click_link "button_realtor_go"
      html = page.html
      File.open("yourfile", 'w') { |file| file.write page.html }
    end
    
  end
  
  def find(property_id)
    data = {}
    data["data"] = {}
    data["photos"] = []
    data["demographics"] = {}
    data["demographics"]["charts"] = {}

    if @sandbox
      details_page = File.read "#{Rails.root}/spec/assets/homer/show.html"
      dems_page = File.read "#{Rails.root}/spec/assets/homer/dems.html"
    else
      property_id = 14045283
      visit "http://beta.realtor.ca/propertyDetails.aspx?PropertyId=#{property_id}"
      details_page = page.html
      page.evaluate_script "showDemographicsTab();"
      dems_page = page.html
    end
    
    begin
      
      ### DETAILS_PAGE
      doc = Nokogiri::HTML::fragment(details_page)
      
      [["listing_id", "listingid"], ["price", "price"]].each do |label, field|
        data[label] = doc.css(".m_property_dtl_info_hdr_lft_#{field}").first.content.split(":").last.strip.gsub(/ /, "")
      end
      
      bbs = doc.css(".m_property_dtl_info_hdr_rgt span")
      data["baths"] = bbs.first.content
      data["beds"] = bbs.last.content
      
      [["location", "Location"], ["property", "Property"]].each do |label, field|
        data["#{label}_description"] = doc.css("#pnl#{field}Description .m_property_dtl_data_tbl_content").first.content.strip.gsub(/ /, "")
      end
      
      doc.css(".m_property_dtl_data_tbl td").each do |td|
        key_field = td.css(".m_property_dtl_data_td_key").first
        key = key_field.content.parameterize.underscore if key_field
        data["data"][key] = td.css(".m_property_dtl_data_td_val").first.content unless key.blank?
      end
      
      doc.css("#photoCarousel a").each do |a|
        data["photos"].push a["href"] if a["class"] =~ /img_/
      end
      
      ### DEMS_PAGE
      doc = Nokogiri::HTML::fragment(dems_page)
      
      doc.css(".m_property_dtl_demographics_top_dtl").each do |dem|
        d = dem.css(".demographic_lbl").first
        dem_label = d.content.parameterize.underscore if d
        data["demographics"][dem_label] = dem.content.gsub(d.content, "").gsub(/\:|\?/, "").strip unless dem_label.blank?
      end
      
      doc.css(".m_property_dtl_demograph_chart_con").each do |chart|
        d = chart.css(".m_property_dtl_demograph_title").first
        dem_label = d.content.parameterize.underscore if d
        data["demographics"]["charts"][dem_label] = chart.css(".m_property_dtl_demograph_chart img").first["src"] unless dem_label.blank?
      end
      
    rescue => e
      data["error"] = e
    end
    data
  end
end
