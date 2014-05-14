class Foldership < ActiveRecord::Base
  belongs_to :folder
  belongs_to :member
  
  validates_presence_of :folder_id, :member_id, :role
  
  def permits?(resource, action)
    return true if resource.is_a?(Object) && resource.try(:creator_id) == member_id
    resource = resource.class.name.downcase.pluralize unless resource.is_a? Symbol
    action = action.to_sym unless action.is_a? Symbol
    r = Foldership.permissions[role.to_sym]
    r.has_key?(resource) && r[resource][action] == true
  end
  
  def self.permissions
    {
      agent: {
        folders: {
          read: true,
          write: true,
          delete: true
        },
        documents: {
          read: true,
          write: true,
          delete: true
        },
        tasks: {
          read: true,
          write: true,
          delete: true
        },
        folderships: {
          read: true,
          write: true,
          delete: true
        }
      },
      client: {
        folders: {},
        documents: {
          read: true
        },
        tasks: {
          read: true
        },
        folderships: {
          read: true
        }
      },
      lawyer: {
        folders: {},
        documents: {
          read: true,
          write: true
        },
        tasks: {},
        folderships: {
          read: true
        }
      }
    }
  end
end
