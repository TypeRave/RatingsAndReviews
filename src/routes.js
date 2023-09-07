const { Router } = require('express');
const controller = require('./controller');

const router = Router();

router.get('/', controller.getReviews);
router.get('/meta', controller.getMetadata);

router.get('/loaderio-4a04c503ebfca60e5df9abf1b047cd81', controller.verify);

router.post('/', controller.postReview);

router.put('/:review_id/helpful', controller.markHelpful);
router.put('/:review_id/report', controller.report);

module.exports = router;


