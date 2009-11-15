class OverviewController < ProjectAreaController
  retrospectiva_extension('overview')

  menu_item :overview do |i|
    i.label = N_('Overview')
    i.rank = 500
    i.path = lambda do |project|
      project_overview_path(project)
    end
  end

  require_permissions :overview,
    :view   => ['index']


  def index
    @changesets = Project.current.changesets.all(
      :include => [:user, :repository],
      :order => 'changesets.created_at DESC',
      :limit => 10)
    @tickets =   Project.current.tickets.all(
        :include => [:user, :changes, :status],
        :order => ['tickets.updated_at DESC', 'ticket_changes.created_at'].compact.join(', '),
        :limit => 10)

    @events = Array.new
    @changesets.each do |changeset|
      @events << {
        :author => changeset.author,
        :user => changeset.user,
        :created_at => changeset.created_at,
        :content => changeset.log,
        :title => "Commit " + changeset.short_revision,
        :link => project_changeset_path(Project.current, changeset)
      }
    end

    @tickets.each do |ticket|
      changes = ""
      author = nil
      user = nil
      if ticket.changes.any?
        changes = "<h4>Comment or change:</h4>"
        if ticket.changes.last.updates?
          ticket.changes.last.updates.each do |property, update|
            changes += "<span class=\"strong\">#{h property}</span> " + overview_ticket_update(update, :em) + "<br />"
          end
          author = ticket.changes.last.author
          user = ticket.changes.last.user
        end
        changes += truncate(ticket.changes.last.content, 200)
        changes += "<br /><br /><hr>"
      else
        changes = "<h4>Created:</h4>"
      end
      content = ""
      content += "<strong>Status:</strong> " + ticket.status.name + "<br />"
      content += "<strong>Priority:</strong> " + ticket.priority.name + "<br />"
      content += "<strong>Assigned to:</strong> " + h(ticket.assigned_user.name) + "<br />" if ticket.assigned_user
      content += "<br />" + truncate(ticket.content, 200)
      @events << {
        :author => author || ticket.author,
        :user => user || ticket.user,
        :created_at => ticket.updated_at,
        :content => changes + content,
        :title => "Ticket [\##{ticket.id}] " + ticket.summary,
        :link => project_ticket_path(Project.current, ticket),
        :title_class => (ticket.status.name == "Fixed" ? "ticket-state-resolved ticket-statement-positive" : "")
      }
    end

    @events.sort! { |a,b| b[:created_at] <=> a[:created_at] }
  end

  private

  def overview_ticket_update(update, tag = nil)
    if !update[:old].blank? && !update[:new].blank?
      RetroI18n._('changed from {{old_value}} to {{new_value}}', :old_value => overview_wrap_update(update[:old], tag), :new_value => overview_wrap_update(update[:new], tag))
    elsif update[:old].blank?
      RetroI18n._('set to {{value}}', :value => overview_wrap_update(update[:new], tag))
    elsif update[:new].blank?
      RetroI18n._('reset (from {{value}})', :value => overview_wrap_update(update[:old], tag))
    end
  end
  def overview_wrap_update(value, tag = nil)
    tag ? "<#{tag}>#{h(value)}</#{tag}>" : h(value)
  end
  
  def truncate(str, len)
    if str.length > len
      str[0..len-1] + "..."
    else
      str
    end
  end
end
