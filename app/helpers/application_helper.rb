module ApplicationHelper
    def formatted_date_ago(datetime)
        return 'Unknown' unless datetime
    
        diff = Time.now - datetime
    
        if diff < 60
            "#{(diff / 60).round} minute#{'s' if (diff / 60).round > 1} ago"
        elsif diff < 3600
            "#{(diff / 3600).round} hour#{'s' if (diff / 3600).round > 1} ago"
        elsif diff < 86400
            "#{(diff / 86400).round} day#{'s' if (diff / 86400).round > 1} ago"
        elsif diff < 604800
            "#{(diff / 604800).round} week#{'s' if (diff / 604800).round > 1} ago"
        elsif diff < 2592000
            "#{(diff / 2592000).round} month#{'s' if (diff / 2592000).round > 1} ago"
        elsif diff < 31536000
            "#{(diff / 31536000).round} year#{'s' if (diff / 31536000).round > 1} ago"
        else
            "#{(diff / 31536000).round} year#{'s' if (diff / 31536000).round > 1} ago"
        end
    end
end
