RetroEM::Routes.draw do |map|

  map.resources :projects do |project|
    project.overview '/overview', :controller => 'overview', :action => 'index'
  end
  
end
