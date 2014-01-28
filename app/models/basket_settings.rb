class BasketSettings
  # ROB:  This class is here to remove settings stored in the acts_as_configurable 
  #       table.
  #       This would be per-object settings with targetable_type = "basket"

  def self.get(name, *args)
    # EOIN: just while we are figuring out how this works
    raise "Woah, we expected just a name but we got the name #{name} and these extras: #{args}" unless args.empty?
    # p "called basket instance #setting. You passed #{name}"

    settings.fetch(name)
  rescue
    :basket_settings_did_not_know_about_setting
  end


  private

  def self.settings
    {
      theme: "",
      fully_moderated: true,
      moderated_except: "",
      theme_font_family: "",
      header_image: "",
      browse_view_as: "",
      show_add_links: false,
      replace_existing_footer: false,
      additional_footer_content: "",
      show_action_menu: "all users"  # ROB: all users can see "Item Details"/"Edit"/... menu for items in a basket.
    }
  end
end
