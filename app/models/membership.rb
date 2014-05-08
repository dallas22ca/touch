class Membership < ActiveRecord::Base
  serialize :permissions, Array
  
  belongs_to :user
  belongs_to :organization

  validates_uniqueness_of :key, scope: :organization
  
  before_validation :parameterize_key, if: :key_changed?
  
  before_create :set_initial_admin
  before_create :permissions
  
  after_create :set_user_data
  after_create :set_key, unless: :key
  
  scope :last_name_asc, -> { order("memberships.data->'last_name' desc") }
  
  def set_user_data
    split = user.name.split(" ")
    d = self.data
    d ||= {}
    d["first_name"] = split.first
    d["last_name"] = split.last == split.first ? "" : split.last
    d["email"] = user.email.to_s
    update_columns data: d
  end
  
  def name
    name = data["first_name"]
    name += " " + data["last_name"] unless data["last_name"].blank? 
  end
  
  def pretty_name
    pretty_name = ""
    pretty_name += "#{data["last_name"]}, " unless data["last_name"].blank?
    pretty_name += data["first_name"]
  end
  
  def parameterize_key
    self.key = key.parameterize
  end
  
  def set_key
    update key: id.to_s
  end
  
  def set_initial_admin
    self.permissions = ["admin"] if organization.memberships.empty?
  end
  
  def set_permissions
    self.permissions ||= ["member"]
  end
  
  def permits?(clearance)
    permissions.include?("admin") || permissions.include?(clearance)
  end
  
  def self.filter(filters = [])
    include_events = false
    normal_fields = ["created_at", "updated_at", "name", "id"]
    queries = []
    memberships = all
    
    if filters
      filters.each do |filter|
        field = filter[:field].to_s
        matcher = filter[:matcher].to_s
        value = filter[:value].to_s
        event = filter[:event].to_s
    
        if field == "q"
          queries.push "LOWER(CAST(avals(memberships.data) AS text)) ilike '%#{q}%'"
        elsif !event.blank?
          include_events = true
          queries.push "EVENT THINGY"
        elsif normal_fields.include? field
          case matcher
          when "is"
            queries.push "memberships.#{field} = '#{value}'"
          when "is_not"
            queries.push "memberships.#{field} != '#{value}'"
          when "like"
            queries.push "memberships.#{field} ilike '%#{value}%'"
          when "greater_than"
            queries.push "memberships.#{field} > '#{value}'"
          when "less_than"
            queries.push "memberships.#{field} < '#{value}'"
          end  
        else
          case matcher
          when "is"
            queries.push "memberships.data @> hstore('#{field}', '#{value}')"
          when "is_not"
            queries.push "memberships.data -> '#{field}' <> '#{value}'"
          when "like"
            queries.push "memberships.data -> '#{field}' ilike '%#{value}%'"
          when "greater_than"
            queries.push "memberships.data -> '#{field}' > '#{value}'"
          when "less_than"
            queries.push "memberships.data -> '#{field}' < '#{value}'"
          end
        end
      end
    end
    
    p queries
    
    memberships = memberships.where(queries.join(" and ")) if queries.any?
    memberships = memberships.includes(:events) if include_events
    memberships
  end
end
