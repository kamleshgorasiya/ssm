const express=require('express')
const jwt=require('jsonwebtoken')
const router=express.Router()
const nodemailer=require('nodemailer');
const con=require('../../database_connection');

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
        return res.status(401).send("Unauthorized Request! Header Not Found");
    }
    let token=req.headers.authorization.split(' ')[1];
    if(token==="null"){
        return res.status(401).send("Unauthorized Request! Token Not Found");
    }
    let payload=jwt.verify(token,'MysupersecreteKey');
   
    if(!payload){
        return res.status(401).send("Unauthorized Request! Token is not Correct");
    }
    req.userId=payload.subject;
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
    let date=new Date();
    date.setDate(date.getDate()+data.days);
    let sql="select * from shopping_cart where cart_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err); 
        } else {
            sql="insert into orders(total_amount,created_on,shipped_on,customer_id,auth_code,shipping_id) values("+amount+",'"+new Date().toISOString().slice(0, 19).replace('T', ' ')+"','"+date.toISOString().slice(0, 19).replace('T', ' ')+"',"+payload.subject+",'"+stripeToken.id+"',"+shipping_id+")";
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
                    
                    for(i=0;i<result.length;i++){
                      let cart=result[i];
                      sql="select * from product_variants where variant_id="+result[i].product_variant_id;
                      con.query(sql,(err,product)=>{
                        if(err) {
                          console.log(err);
                        } else {
                          sql="insert into order_detail(order_id,product_variant_id,attributes,quantity,customer_id,user_id,unit_cost) values("+order_id+","+product[0].variant_id+",'"+cart.attributes+"',"+cart.quantity+","+payload.subject+","+product[0].user_id+","+product[0].price+")";
                          con.query(sql,(err,details)=>{
                              if(err){
                                  console.log(err);
                              } else {
                                  
                              }
                          })
                        }
                      })
                      
                    }
                    if(i==result.length){
                        sql="delete from shopping_cart where cart_id="+payload.subject;
                        con.query(sql,(err,cart)=>{
                        if(err){
                            console.log(err);
                        } else {
                          res.status(200).send({message:"Order Placed Successfully"});
                            sql="select * from customer where customer_id="+payload.subject;
                            con.query(sql,(err,user)=>{
                              if(err){
                                console.log(err);
                              } else {
                                let email=user[0].email;
                                var mailOptions = {
                                    from: 'youremail@gmail.com',
                                    to: email,
                                    subject: 'Order Confirmation',
                                    html:'<h1>Order Recieved</h1><br>Order No. '
                                  };
                                transporter.sendMail(mailOptions,(err,info)=>{
                                    if(err){
                                        console.log(err);
                                    } else {
                                        
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

router.get('/orderDetail',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let response=new Array();
    let sql="select * from orders where customer_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
          if(result.length>0){
            response.push(result);
            sql="select * from order_detail where customer_id="+payload.subject+" order by customer_id";
            con.query(sql,(err,orderDetail)=>{
              if(err){
                console.log(err);
              } else {
                response.push(orderDetail);
                sql="select * from product_variants where variant_id in(";
                for(let i=0;i<orderDetail.length;i++){
                  if(i==0){
                    sql=sql+orderDetail[i].product_variant_id;
                  } else {
                    sql=sql+","+orderDetail[i].product_variant_id;
                  }
                }
                sql=sql+")";
                con.query(sql,(err,products)=>{
                  if(err){
                    console.log(err);
                  } else {
                    response.push(products);
                    sql="select * from product where product_id in(";
                    for(let i=0;i<products.length;i++){
                      if(i==0){
                        sql=sql+products[i].product_id;
                      }  else {
                        sql=sql+","+products[i].product_id;
                      }
                    }
                    sql=sql+")";
                
                    con.query(sql,(err,commonProduct)=>{
                      if(err){
                        console.log(err);
                      } else {
                        response.push(commonProduct);
                        sql="select * from status";
                        con.query(sql,(err,status)=>{
                          if(err){
                            console.log(err)
                          } else {
                            response.push(status);
                            res.json(response);
                          }
                        })
                      }
                    })
                  }
                })
              }
            })
          } else {
            res.status(400).json({message:"No Order Found",success:true})
          }
            
        }
    })
})

router.post('/cancelOrder',verifyToken,(req,res)=>{
  let token=req.headers.authorization.split(' ')[1];
  let payload=jwt.verify(token,'MysupersecreteKey');
  let order=req.body;
  let sql="update order_detail set cancel_bit=1 where order_id="+order.order_id+" and product_variant_id="+order.product_id +" and customer_id="+payload.subject;
  con.query(sql,(err,result)=>{
    if(err){
      console.log(err);
    } else {
      res.json([{"message":"Item is cancelled"}]);
    }
  })
})
module.exports=router