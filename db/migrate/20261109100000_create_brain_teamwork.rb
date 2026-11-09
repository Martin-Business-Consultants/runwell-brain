# Brain 0.3: the sections an install keeps (brain_kinds: named, ordered, for clients, work or both,
# and work types; always in AI briefs or when relevant), every version of a section (brain_revisions),
# a keeper per brain (brain_subjects) who gets a review task when a section goes stale, a log of
# decisions (brain_decisions) and questions an agent asked that a person answers (brain_questions).
class CreateBrainTeamwork < ActiveRecord::Migration[8.1]
  def change
    create_table :brain_kinds do |t|
      t.string :key, null: false
      t.string :label, null: false
      t.string :hint
      t.integer :position, null: false, default: 0
      t.string :applies_to, null: false, default: "both"
      t.json :work_labels
      t.boolean :always_in_brief, null: false, default: false
      t.datetime :archived_at
      t.timestamps
    end
    add_index :brain_kinds, :key, unique: true

    create_table :brain_revisions do |t|
      t.integer :section_id, null: false
      t.text :body
      t.integer :written_by_id
      t.string :via
      t.timestamps
    end
    add_index :brain_revisions, :section_id

    create_table :brain_subjects do |t|
      t.string :subject_type, null: false
      t.integer :subject_id, null: false
      t.integer :keeper_id
      t.timestamps
    end
    add_index :brain_subjects, %i[subject_type subject_id], unique: true

    add_column :brain_sections, :review_task_id, :integer

    create_table :brain_decisions do |t|
      t.string :subject_type, null: false
      t.integer :subject_id, null: false
      t.date :decided_on, null: false
      t.text :decision, null: false
      t.text :why
      t.string :decided_by
      t.integer :task_id
      t.integer :created_by_id
      t.timestamps
    end
    add_index :brain_decisions, %i[subject_type subject_id decided_on]

    create_table :brain_questions do |t|
      t.string :subject_type, null: false
      t.integer :subject_id, null: false
      t.string :key
      t.text :question, null: false
      t.integer :task_id
      t.integer :asked_by_id
      t.text :answer
      t.integer :answered_by_id
      t.datetime :answered_at
      t.timestamps
    end
    add_index :brain_questions, %i[subject_type subject_id]
    add_index :brain_questions, :task_id
  end
end
