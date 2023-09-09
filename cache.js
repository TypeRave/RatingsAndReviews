const { LRUCache } = require('lru-cache');
const reviewCache = new LRUCache({
  max: 100000,
  //10min cache
  ttl: 600000
});
const metaCache = new LRUCache({
  max: 100000,
  ttl: 600000
});

function addToReviewCache(key, data) {
  reviewCache.set(key, data);
};

function getFromReviewCache(key) {
  return reviewCache.get(key);
};

function addToMetaCache(key, data) {
  metaCache.set(key, data);
};

function getFromMetaCache(key) {
  return metaCache.get(key);
};

module.exports = {
  addToReviewCache,
  getFromReviewCache,
  addToMetaCache,
  getFromMetaCache
};