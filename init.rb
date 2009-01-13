require File.dirname(__FILE__) + "/lib/has_calendar"

ActionView::Base.send :include, MilkIt::Calendar::ActionView
