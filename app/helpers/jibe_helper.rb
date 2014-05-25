module JibeHelper
  def jibe *args
    if args.try(:last).is_a? Hash
      strategy = args.try(:last)[:strategy]
      restrict_to = args.try(:last)[:restrict_to]
    end
    
    strategy = "append" if strategy.blank?
    resource = "#{args.first.first.class.name}".downcase.pluralize
    data = { 
      strategy: strategy, 
      resource: resource
    }
    
    if restrict_to
      data[:restrict_to] = []
      
      if restrict_to.is_a? Array
        restrict_to.each do |restrict|
          data[:restrict_to].push "#{restrict.class.name.downcase}-#{restrict.id}"
        end
      else
        data[:restrict_to].push "#{restrict_to.class.name.downcase}-#{restrict_to.id}"
      end
      
      data[:restrict_to] = data[:restrict_to].join(",")
    end
    
    html = content_tag :script, nil, type: "x-jibe", data: data
    html += render *args
    html.html_safe
  end
end