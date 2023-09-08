const LRU = require('lru-cache');
const reviewCache = new LRU({ max: 1000 });
const metaCache = new LRU({ max: 1000 });

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