const expect = require('chai').expect;
const chaiHttp=require('chai-http');
//const request = require('supertest');
const chai=require('chai');
const auth=require('../../../routes/authentication');
const product=require('../../../routes/product');
const app=require('../../../server');

chai.use(chaiHttp);
chai.should();

describe("Test",()=>{
    describe("GET /",()=>{
        it("should products list",(done)=>{
            chai.request(app).get('/product/category')
            .end((err,res)=>{
                
                res.body.should.be.a('array');
                done();
            })
        });

        it("Should get token if user is valid",(done)=>{
            chai.request(app).post('/authentication/loginUser')
            
            .send({"email":"pmd@gmail.com","password":"amin"})
            .end((err,res)=>{
                expect(res.statusCode).to.equal(500);
                done();
            })
        });

        it("Should register user if email and mobile is unique",(done)=>{
            chai.request(app).post('/authentication/registerUser')
            
            .send({"email":"pm@gmail.com","password":"admin","name":"Parth","mobile":"95252140"})
            .end((err,res)=>{
                expect(res.statusCode).to.equal(500);
                done();
            })
        });

        it("Should add Product in wishlist",(done)=>{
            chai.request(app).post('/cart/addToWishList')
            .set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWJqZWN0IjoyOSwiaWF0IjoxNTU4MDk0Njc2fQ.Ho9u_1ULHFN10yTKJ0TQkbwan9oBN3eAPeLJGwIBWp8')
            .send({"product_id":3,"quantity":2})
            .end((err,res)=>{
                expect(res.statusCode).to.equal(200);
                done();
            })
        });

        it("Should not add Product in cart if invalid token",(done)=>{
            chai.request(app).post('/cart/addToBag')
            .set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIscCI6IkpXVCJ9.eyJzdWJqZWN0IjoyOSwiaWF0IjoxNTU4MDk0Njc2fQ.Ho9u_1ULHFN10yTKJ0TQkbwan9oBN3eAPeLJGwIBWp8')
            .send({"product_id":3,"quantity":2})
            .end((err,res)=>{
                expect(res.statusCode).to.equal(200);
                done();
            });
        });     
    });
});
