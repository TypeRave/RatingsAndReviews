const { LRUCache } = require('lru-cache');

const reviewCache = new LRUCache({
  max: 50000,
  //10min cache
  ttl: 600000
});
const metaCache = new LRUCache({
  max: 50000,
  ttl: 600000
});

function addToReviewCache(key, data) {
  const stringified = JSON.stringify(data);
  reviewCache.set(key, stringified);
};

function getFromReviewCache(key) {
  return JSON.parse(reviewCache.get(key));
};

function addToMetaCache(key, data) {
  const stringified = JSON.stringify(data);
  metaCache.set(key, stringified);
};

function getFromMetaCache(key) {
  return JSON.parse(metaCache.get(key));
};

module.exports = {
  addToReviewCache,
  getFromReviewCache,
  addToMetaCache,
  getFromMetaCache
};