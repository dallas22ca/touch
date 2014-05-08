class Organization < ActiveRecord::Base
  serialize :modules, Array

  has_many :members
  has_many :users, through: :members
  has_many :rooms
  has_many :events
  
  validates_uniqueness_of :permalink
  
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
          table = include_events ? "events" : "members"
        
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
end
