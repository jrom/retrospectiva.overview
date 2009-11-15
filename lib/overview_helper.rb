module OverviewHelper
  def include_overview_stylesheet
    content_for :header do
      x_stylesheet_link_tag('overview')      
    end
  end
end
