const express=require('express')
const jwt=require('jsonwebtoken')
const router=express.Router()
const nodemailer=require('nodemailer');


const mysql=require('mysql');

const con=mysql.createConnection({
    host:"localhost",
    user:"root",
    password:"",
    database:"ssm"
});

var transporter = nodemailer.createTransport({
    host:'smtp.gmail.com',
    port:587,
    secure:false,
    requireTLS: true,
    auth: {
      user: 'pmdhankecha.18@gmail.com',
      pass: '260519991999'
    }
  });

function verifyToken(req,res,next){
    if(!req.headers.authorization){
        return res.status(401).send('Unauthorized Request1');
    }
    let token=req.headers.authorization.split(' ')[1];
    if(token==="null"){
        return res.status(401).send("Unauthorized Request2");
    }
    let payload=jwt.verify(token,'MysupersecreteKey');
   
    if(!payload){
        return res.status(401).send("Unauthorized Request3");
    }
    req.userId=payload.subject;
    //console.log(req.userId);
    next(); 
}

router.post('/checkout',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let data=req.body;
    let stripeToken=data.stripeToken;
    let amount=data.amount;
    let shipping_id=data.shipping_id;
    let shipped_on=new Date().toISOString().slice(0, 19).replace('T', ' ');
    
    let sql="select * from shopping_cart where cart_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err); 
        } else {
            sql="insert into orders(total_amount,created_on,shipped_on,customer_id,auth_code,shipping_id) values("+amount+",'"+new Date().toISOString().slice(0, 19).replace('T', ' ')+"','"+shipped_on+"',"+payload.subject+",'"+stripeToken.id+"',"+shipping_id+")";
            con.query(sql,(err,orders)=>{
                if(err){
                    console.log(err);
                } else {
                    sql="select * from orders where auth_code='"+stripeToken.id+"'";
                    con.query(sql,(err,order)=>{
                        if(err){
                            console.log(err);
                        } else {
                            let order_id=order[0].order_id;
                            let i;
                            console.log("length  "+result.length)
                            for(i=0;i<result.length;i++){
                                sql="insert into order_detail(order_id,product_id,attributes,quantity) values("+order_id+","+result[i].product_id+",'"+result[i].attributes+"',"+result[i].quantity+")";
                                con.query(sql,(err,details)=>{
                                    if(err){
                                        console.log(err);
                                    } else {
                                                
                                    }
                                
                                })
                                
                            }
                            if(i==result.length){
                                sql="delete from shopping_cart where cart_id="+payload.subject;
                           
                                con.query(sql,(err,cart)=>{
                                if(err){
                                    console.log(err);
                                } else {
                                    sql="select * from customer where customer_id="+payload.subject;
                                    console.log(sql)
                                    con.query(sql,(err,user)=>{
                                        if(err){
                                            console.log(err);
                                        } else {
                                            let email=user[0].email;
                                            var mailOptions = {
                                                from: 'youremail@gmail.com',
                                                to: email,
                                                subject: 'Order Confirmation',
                                                html:'<h1>Order Recieved</h1><br>'

                                              };
                                            transporter.sendMail(mailOptions,(err,info)=>{
                                                if(err){
                                                    console.log(err);
                                                } else {
                                                    res.status(200).send({message:"Order Placed Successfully"});
                                                }
                                            })
                                              
                                        }
                                    })
                                    
                                    
                                }
                            })
                            }
                        }
                    })
                }
            })
        }
    })
    
})

// router.get('/serOrderDetail',verifyToken,(req,res)=>{
//     let token=req.headers.authorization.split(' ')[1];
//     let payload=jwt.verify(token,'MysupersecreteKey');
//     let orderIds;
//     let sql="select * from orders where customer_id="+payload.subject;
//     con.query(sql,(err,orders)=>{
//         if(err){
//             console.log(err);
//         } else {
//             ordersIds=orders;
//             for(let i=0;i<ordersIds.length;i++){
//                 sql="select name from product where product_id="
//             }
//         }
//     })
// })

router.get('/orderDetail',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select * from orders where customer_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

module.exports=router