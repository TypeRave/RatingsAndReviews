import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // vus: 1000,
  // duration: '60s',
  thresholds: {
    http_req_failed: ['rate<0.01'], // http errors should be less than 1%
    http_req_duration: ['p(95)<2000'], // 95% of requests should be below 2000ms
  },
  stages: [
    { duration: '10s', target: 1000 }, //ramp up to 1000 vus
    { duration: '60s', target: 1000 }, //hold 1000 vus for 60s
    { duration: '10s', target: 0 } //graceful ramp down
  ]
};

export default function () {
  const max = 900000;
  const min = 800000;
  const product_id = Math.floor(Math.random() * (max - min) + min);

  //const localURL = `http://localhost:3000/reviews/?product_id=${product_id}`;
  const localURL = `http://localhost:3000/reviews/meta/?product_id=${product_id}`;
  http.get(localURL);
  sleep(1); // tell virtual user to rest before trying again
};

