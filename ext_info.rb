RetroAM.permission_map do |map|

  map.resource :overview, :label => N_('Overview') do |pages|
    pages.permission :view,   :label => N_('View')
  end

end
