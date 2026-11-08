# The plugin's own table, prefixed with its key: one row per section of a client's or a piece of
# work's brain, made the first time it's written. Safe on a live install.
class CreateBrainSections < ActiveRecord::Migration[8.1]
  def change
    create_table :brain_sections do |t|
      t.string :subject_type, null: false
      t.integer :subject_id, null: false
      t.string :key, null: false
      t.text :body
      t.integer :updated_by_id
      t.integer :confirmed_by_id
      t.datetime :confirmed_at
      t.timestamps
    end
    add_index :brain_sections, %i[subject_type subject_id key], unique: true
  end
end
