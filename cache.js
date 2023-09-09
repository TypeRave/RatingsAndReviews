const { LRUCache } = require('lru-cache');
const pako = require('pako');

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
  const compressed = pako.deflate(JSON.stringify(data));
  reviewCache.set(key, compressed);
};

function getFromReviewCache(key) {
  const compressed = reviewCache.get(key);
  return JSON.parse(pako.inflate(compressed, { to: 'string' }));
};

function addToMetaCache(key, data) {
  const compressed = pako.deflate(JSON.stringify(data));
  metaCache.set(key, compressed);
};

function getFromMetaCache(key) {
  const compressed = metaCache.get(key);
  return JSON.parse(pako.inflate(compressed, { to: 'string' }));
};

module.exports = {
  addToReviewCache,
  getFromReviewCache,
  addToMetaCache,
  getFromMetaCache
};