class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :release_year
      t.text :summary
      t.string :trailer
      t.string :poster
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
  end
end
