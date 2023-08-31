const mongoose = require('mongoose');

main().catch(err => console.log(err));

async function main() {
  await mongoose.connect('mongodb://127.0.0.1:27017/ratings_reviews');
}

//subdocument
const photoSchema = new mongoose.Schema({
  id: Number;
  url: String,
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

const Product = new mongoose.Schema({
  id: Number,
  characteristics: [String],
});

const Review = mongoose.model('Review', reviewSchema);
const Product = mongoose.model('Product', productSchema);


//Queries I'll need:
/*
Reviews: aggregate -> sum of all reviews by product id, grouped by star rating. return 5 totals
Recommended: aggregate -> sum of all reviews by product id, grouped by reccommended true/false. return 2 totals
Characteristics: aggregate -> avg of all reviews by product id, filter by characteristics in Product model, return totals for all characteristics
*/