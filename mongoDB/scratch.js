const mongoose = require('mongoose');

main().catch(err => console.log(err));

async function main() {
  await mongoose.connect('mongodb://127.0.0.1:27017/ratings_reviews');
}

//subdocument
const photoSchema = new mongoose.Schema({
  id: Number;
  url: String;
});
//main document
const reviewSchema = new mongoose.Schema({
  review_id: Number,
  product_id: Number,
  rating: Number,
  date: Date,
  summary: String,
  recommended: Boolean,
  response: String,
  body: String,
  reviewer_name: String,
  helpfulness: Number,
  photos: [photoSchema],
  fit: Number, //use descriptive names instead of characteristic IDs moving forward
  length: Number,
  comfort: Number,
  quality: Number,
  size: Number,
  width: Number,
  reported: Boolean,
});

const Review = mongoose.model('Review', reviewSchema)

//make metadata collection a "view"
const metadataSchema = new mongoose.Schema({
  product_id: Number,
  rating_1: Number,
  rating_2: Number,
  rating_3: Number,
  rating_4: Number,
  rating_5: Number,
  recommended_true: Number,
  recommended_false: Number,
  fit_avg: Number,
  length_avg: Number,
  width_avg: Number,
  comfort_avg: Number,
  quality_avg: Number,
  size_avg: Number,
}, { autoCreate: false, autoIndex: false}); //disable for views because we want to create on demand

const Metadata = mongoose.model('Metadata', metadataSchema);
// I would attempt to create a "view"
// await Metadata.createCollection(
//   viewOn: 'reviews',
//   pipeline: [{ $set: {rating_1: { }... //create agreggation logic...}, ...} ]);
