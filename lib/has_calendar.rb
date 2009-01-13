module MilkIt
  module Calendar
    module ActionView
      def calendar(options={}, &block)
        today = Date.today
        options = {
          :year => today.year,
          :month => today.month,
          :today => nil,
          :events => nil,
          :field => :created_at,
          :header_format => 'date.abbr_day_names',
          :caption_format => :default
        }.merge(options)
        date = Date.new(options[:year], options[:month], today.day)
      
        days = (date.beginning_of_month..date.end_of_month).to_a
        days.first.wday.times {|t| days.unshift(nil)}
        
        # group all records if data is provided
        records = options[:events].group_by{|e| e.send(options[:field]).to_date.day} if options[:events]
      
        # building the calendar
        table = content_tag(:table, :id => 'calendar') do
          # first, get the header
          caption = content_tag(:caption, l(date, :format => options[:caption_format]))

          day_names = t(options[:header_format])
          head = content_tag(:thead) do
            content_tag(:tr) do
              (0..6).collect { |i| content_tag(:th, day_names[i]) }.join
            end
          end
        
          # then get the body
          body = content_tag(:tbody) do
            days.in_groups_of(7).inject('') do |rows, group|
              rows << content_tag(:tr) do
                group.inject('') do |cols, day|
                  classes = []
                  events = nil
                
                  cols << content_tag(:td, unless day.nil?
                    classes.push('today') if today.eql?(day)
                    classes.push('weekend') if [0, 6].include?(day.wday)
                
                    events = if block_given?
                      classes.push('events') unless records[date.to_s(:number)].blank?

                      if options[:events]
                        capture(day, records[day.day], &block)
                      else
                        capture(day, &block)
                      end
                    end
  
                    day = options[:today] if options[:today] && date == today
                    events.nil?? content_tag(:span, day.day) : events
                  end, classes.empty?? nil : {:class => col_classes.join(' ')})
                end
              end
            end
          end
       
          # And put all together
          "#{caption}#{head}#{body}"
        end
      
        if block_given?
          concat(table)
        else
          return table
        end
      end
    end
  end
end
