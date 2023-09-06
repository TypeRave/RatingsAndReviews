const { Router } = require('express');
const controller = require('./controller');

const router = Router();

router.get('/', controller.getReviews);
router.get('/meta', controller.getMetadata);

router.post('/', controller.postReview);

router.put('/:review_id/helpful', controller.markHelpful);
router.put('/:review_id/report', controller.report);

module.exports = router;