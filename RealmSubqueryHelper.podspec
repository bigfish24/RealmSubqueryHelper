Pod::Spec.new do |s|
  s.name         = "RealmSubqueryHelper"
  s.version      = "0.0.1"
  s.summary      = "Adds support for SUBQUERY in Realm queries."
  s.description  = <<-DESC
Need to query a `RLMObject` against a to-many relationship using multiple properties? This category brings the hidden gem in `NSPredicate`, `SUBQUERY`, to Realm.
                   DESC

  s.homepage     = "https://github.com/bigfish24/RealmSubqueryHelper"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Adam Fish" => "af@realm.io" }
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/bigfish24/RealmSubqueryHelper.git", :tag => "0.0.1" }
  s.source_files  = "RLMObject+Subquery.h", "RLMObject+Subquery.m"
  s.requires_arc = true
  s.dependency "Realm"

end
