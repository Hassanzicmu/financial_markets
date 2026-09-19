require 'xcodeproj'

project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

group = project.main_group.find_subpath(File.join('Runner'), true)

en_file = 'ios/Runner/en.lproj/InfoPlist.strings'
ar_file = 'ios/Runner/ar.lproj/InfoPlist.strings'

# Create variant group if it doesn't exist
variant_group = group.children.find { |c| c.name == 'InfoPlist.strings' && c.class == Xcodeproj::Project::Object::PBXVariantGroup }
if variant_group.nil?
  variant_group = group.new_variant_group('InfoPlist.strings')
end

# Add files to variant group
en_ref = variant_group.children.find { |c| c.name == 'en' }
if en_ref.nil?
  en_ref = variant_group.new_reference(en_file)
  en_ref.name = 'en'
end

ar_ref = variant_group.children.find { |c| c.name == 'ar' }
if ar_ref.nil?
  ar_ref = variant_group.new_reference(ar_file)
  ar_ref.name = 'ar'
end

# Add to targets
project.targets.each do |target|
  if target.name == 'Runner'
    unless target.resources_build_phase.files.any? { |f| f.file_ref == variant_group }
      target.resources_build_phase.add_file_reference(variant_group)
    end
  end
end

project.save
puts "Added localization files to Xcode project."
