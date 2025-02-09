const express=require('express')
const jwt=require('jsonwebtoken')
const router=express.Router()
const con=require('../../database_connection');

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

router.post('/addToWishList',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let product=req.body;
    let sql="select * from wishlist where product_variant_id="+product.product_id+" and wishlist_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(result.length==0){
                sql="insert into wishlist(wishlist_id,product_variant_id,quantity,added_on) values("+payload.subject+","+product.product_id+","+product.quantity+",'"+new Date().toISOString().slice(0, 19).replace('T', ' ')+"')";
                con.query(sql,(err,result1)=>{
                    if(err){
                        console.log(err);
                        res.status(500).send("Internal error")
                    }
                })
            }
            let message={"message":"Added to WishList successfully"}
            res.status(200).send(message);
        }
    })
    
})

router.post('/moveToWishlist',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let cart=req.body;
    let sql="select * from shopping_cart where item_id="+cart.item_id;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            sql="select * from wishlist where product_variant_id="+result[0].product_variant_id+" and wishlist_id="+payload.subject;
            
            con.query(sql,(err,wishlist)=>{
                if(err){
                    console.log(err);
                } else {
                    if(wishlist.length==0){
                        sql="insert into wishlist(wishlist_id,product_variant_id,attributes,quantity,added_on) values("+result[0].cart_id+","+result[0].product_variant_id+",'"+result[0].attributes+"',"+result[0].quantity+",'"+result[0].added_on+"')";
                    
                        con.query(sql,(err,wishlistData)=>{
                            if(err){
                                console.log(err);
                            }
                        })
                    }
                    sql="delete from shopping_cart where item_id="+result[0].item_id;
                    con.query(sql,(err,deleted)=>{
                        if(err){
                            console.log(err);
                        } else {
                            let message={message:"Moved to Wishlisdt successfully"};
                            res.status(200).send(message);
                        }
                    })
                }
            })
            
        }
    })
})

router.post('/addToBag',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let product=req.body;
    let sql="select * from shopping_cart where cart_id="+payload.subject+" and product_variant_id="+product.product_id;
    con.query(sql,(err,products)=>{
        if(err){
            console.log(err);
        } else {
            let flag=0;
            if(products.length>0){
                for(let i=0;i<products.length;i++){
                    if(products[i].attributes==product.attributes){
                        flag=1;
                        break;
                    }
                }
                if(flag==0){
                    sql="insert into shopping_cart(cart_id,product_variant_id,attributes,quantity,added_on) values("+payload.subject+","+product.product_id+",'"+product.attributes+"',"+product.quantity+",'"+new Date().toISOString().slice(0, 19).replace('T', ' ')+"')";
                    con.query(sql,(err,result)=>{
                        if(err){
                            console.log(err);
                        } else {
                            let message=[{"message":"Added to bag successfully"}];
                            res.status(200).json(message);
                        }
                    })
                } else {
                    let message=[{"message":"This product is already added in bag"}];
                    res.status(200).json(message);
                }
            } else {
                sql="insert into shopping_cart(cart_id,product_variant_id,attributes,quantity,added_on) values("+payload.subject+","+product.product_id+",'"+product.attributes+"',"+product.quantity+",'"+new Date().toISOString().slice(0, 19).replace('T', ' ')+"')";
                con.query(sql,(err,result)=>{
                    if(err){
                        console.log(err);
                    } else {
                        let message=[{"message":"Added to cart successfully"}];
                        res.status(200).json(message);
                    }
                })
            }
        }
    })
})

router.post('/addToBagWishlist',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let product=req.body;
    let sql="insert into shopping_cart(cart_id,product_variant_id,attributes,quantity,added_on) values("+payload.subject+","+product.product_id+",'"+product.attributes+"',"+product.quantity+",'"+new Date().toISOString().slice(0, 19).replace('T', ' ')+"')";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            sql="delete from wishlist where product_variant_id="+product.product_id+" and wishlist_id="+payload.subject;
            con.query(sql,(err,delres)=>{
                if(err){
                    console.log(err);
                } else {
                    let message={"message":"Added to cart successfully"}
                    res.status(200).send(message);
                }
            })   
        }
    })
})

router.post('/updateQuantity',verifyToken,(req,res)=>{
    let cart=req.body;
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="update shopping_cart set quantity="+cart.quantity+" where item_id="+cart.item_id+" and cart_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            let message={"message":"Updated quantity successfully"};
            res.status(200).send(message);
        }
    })
})

router.post('/removeCart',verifyToken,(req,res)=>{
    let cart=req.body;
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="delete from shopping_cart where item_id="+cart.item_id+" and cart_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            let message={"message":"Removed cart successfully"};
            res.status(200).send(message);
        }
    })
})

router.post('/addLocalBags',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let products=req.body;
    for(let i=0;i<products.length;i++){
        let sql="insert into shopping_cart(cart_id,product_variant_id,attributes,quantity,added_on) values("+payload.subject+","+products[i].product_id+",'"+products[i].attributes+"',"+products[i].quantity+",'"+new Date().toISOString().slice(0,19).replace('T',' ')+"')";
        con.query(sql,(err,result)=>{
            if(err){
                console.log(err);
            }
        })
    }
    let message={"message":"Added to cart successfully"}
    res.status(200).send(message);
})

router.get('/countCartItem',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let product=req.body;
    let sql="select count(item_id) as cartItem from shopping_cart where cart_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/countWishlistItem',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let sql="select count(item_id) as wishlistItem from wishlist where wishlist_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err+"asdawsd");
        } else {
            res.json(result);
        }
    })
})

router.post('/removeWishlist',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let product=req.body;
    let sql="delete from wishlist where product_variant_id="+product.product_id+" and wishlist_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            let message={"message":"Product Deleted successfully"};
            res.status(200).send(message);
        }
    })
})

router.post('/checkWishlist',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let wishlist=req.body;
    let sql="select * from wishlist where product_variant_id="+wishlist.product_id+" and wishlist_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            let response={length:res.length};
            res.status(200).send(response);
        }
    })
})

router.get('/getCartProducts',verifyToken,(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let response=new Array();
    let sql="select * from shopping_cart where cart_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            
            if(result.length>0){
                sql="select * from product_variants where variant_id in(";
                for(let i=0;i<result.length;i++){
                    if(i==0){
                        sql=sql+result[i].product_variant_id;
                    }else{
                        sql=sql+","+result[i].product_variant_id;
                    }
                }
                sql=sql+")";
                con.query(sql,(err,products)=>{
                    if(err){
                        console.log(err);
                    } else {
                        response.push(result);
                        response.push(products);
                        res.json(response);
                    }
                })
            } else {
                let result_data=new Array();
                result_data.push(new Array());
                result_data.push(new Array());
                res.json(result_data);
            }
        }
    })
})

router.get('/getWishlistProduct',(req,res)=>{
    let token=req.headers.authorization.split(' ')[1];
    let payload=jwt.verify(token,'MysupersecreteKey');
    let response=new Array();
    let sql="select * from wishlist where wishlist_id="+payload.subject;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err); 
        } else {
            let id=[];
            for(let i=0;i<result.length;i++){
                id.push(result[i].product_variant_id);
            }
            id=Array.from(new Set(id));
            if(id.length>0){
                sql="select * from product_variants where variant_id in(";
            for(let i=0;i<id.length;i++){
                if(i==0){
                    sql=sql+id[i];
                }else{
                    sql=sql+","+id[i];
                }
            }
            sql=sql+")";
            con.query(sql,(err,products)=>{
                if(err){
                    console.log(err);
                } else {
                    response.push(result);
                    response.push(products);
                    res.json(response);
                }
            })
            } else {
                let result_data=new Array();
                result_data.push(new Array());
                result_data.push(new Array());
                res.json(result_data);
            }
            
        }
    })
})

module.exports=router