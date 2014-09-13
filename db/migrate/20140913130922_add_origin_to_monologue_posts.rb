class AddOriginToMonologuePosts < ActiveRecord::Migration
  def change
    add_column :monologue_posts, :origin, :string
  end
end
