require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

group = project.main_group.find_subpath(File.join('Runner'), true)

variant_group = group.children.find { |c| c.name == 'InfoPlist.strings' && c.class == Xcodeproj::Project::Object::PBXVariantGroup }

if variant_group
  variant_group.children.each do |child|
    if child.name == 'en'
      child.path = 'en.lproj/InfoPlist.strings'
      child.source_tree = '<group>'
    elsif child.name == 'ar'
      child.path = 'ar.lproj/InfoPlist.strings'
      child.source_tree = '<group>'
    end
  end
  project.save
  puts "Fixed paths in pbxproj!"
else
  puts "Variant group not found."
end
