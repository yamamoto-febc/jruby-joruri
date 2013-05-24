class Sys::GroupChangeItem < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::GroupChange::Base
  include Sys::Model::GroupChange::Temporal


end
