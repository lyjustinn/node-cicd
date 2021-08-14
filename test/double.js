require('dotenv').config();

process.env.NODE_ENV = 'test';

const double = require('../util/double');

const chai = require('chai');
const chaiHttp = require('chai-http');
const app = require('../app');
const should = chai.should();

chai.use(chaiHttp);

describe("Double", () => {

    describe('/GET double', () => {
        it('should return double the number in an object', (done) => {
            chai.request(app)
                .get('/api/double/2')
                .end((err, res) => {
                    res.should.have.status(200);
                    res.body.should.be.a('object');
                    res.body.should.have.property('double');
                    res.body.should.have.property('double').eql(4);
                    done();
                });
        });
    });

    describe('/GET triple', () => {
        it('should return triple the number in an object', (done) => {
            chai.request(app)
                .get('/api/triple/2')
                .end((err, res) => {
                    res.should.have.status(200);
                    res.body.should.be.a('object');
                    res.body.should.have.property('triple');
                    res.body.should.have.property('triple').eql(6);
                    done();
                });
        });
    })
})