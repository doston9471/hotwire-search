# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Post.destroy_all
p 'All posts destroyed'
p
p 'Creating posts ...'
1000.times do |data|
  Post.create!(
    title: Faker::Movie.title,
    description: Faker::Movie.quote,
    body: Faker::Lorem.paragraph(sentence_count: 5)
  )
end
p "#{Post.count} Posts created !!!"