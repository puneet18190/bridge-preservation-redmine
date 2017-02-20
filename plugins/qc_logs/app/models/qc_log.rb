class QcLog < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :user
  scope :visible, lambda {|*args| joins(:project).where(Project.allowed_to_condition(args.shift || User.current, :view_qc_logs)) }

end
