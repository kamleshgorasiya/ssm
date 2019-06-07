const express=require('express')
const router=express.Router()
const con=require('../../database_connection');
const limit=15;

router.get('/allProducts/:up',function(req,res){
    let up=req.params.up;
    if(isNaN(up)){
        res.status(500).send("Unauthorized request");
    }
    let sql="select * from product_variants where parent=1 limit "+up+","+limit;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            let products=result;
            if(products.length>0){
                sql="select * from product where product_id in(";
                for(i=0;i<products.length;i++){
                    if(i==0){
                        sql=sql+products[i].product_id;
                    } else {
                        sql=sql+","+products[i].product_id;
                    }
                }
                sql=sql+")";
                con.query(sql,(err,product)=>{
                    if(err){
                        console.log(err);
                    } else {
                        let response=new Array();
                        response.push(products);
                        response.push(product);
                        res.json(response);
                    }
                })
            } else {
                res.json(result);
            }
        }
    })
})

router.get('/productById/:id',(req,res)=>{
    let id=req.params.id;
    if(isNaN(id)){
        res.status(500).send("Unauthorized Request");
    }
    let sql="select * from product_variants where product_id=(select product_id from product_variants where variant_id="+id+")";
    con.query(sql,(err,result)=>{
        if(err) {
            console.log(err);
        } else {
           if(result.length>0){
            sql="select * from product where product_id="+result[0].product_id;
            con.query(sql,(err,product)=>{
                if(err){
                    console.log(err);
                } else {
                    sql="select * from attribute_value";
                    con.query(sql,(err,attributes)=>{
                        if(err){
                            console.log("err");
                        } else {
                            let response=new Array();
                            response.push(result);
                            response.push(product);
                            response.push(attributes);
                            res.json(response);
                        }
                    })
                }
             })
           } else {
               res.json(result);
           }
        }
    })
})

router.get('/getVariants/:product_id',(req,res)=>{
    let product_id=req.params.product_id;
    if(isNaN(product_id)){
        res.status(500).send("Unauthorized Reuest");
    }
    let sql="select * from product_variants where product_id=(select product_id from product_variants where variant_id="+product_id+")";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            sql="select * from attribute_value";
            con.query(sql,(err,attributes)=>{
                if(err){
                    console.log(err);
                } else {
                    let response=new Array();
                    response.push(result);
                    response.push(attributes);
                    res.json(response);
                }
            })
        }
    })
})

router.get('/countProduct',(req,res)=>{
    let sql="select count(*) as countp from product";
    con.query(sql,function(err,result){
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/category',(req,res)=>{
    let sql="select * from category";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
             res.json(result);
        }
    })
})

router.get('/productByCategory/:category_id/:up',(req,res)=>{
    let category=req.params.category_id;
    let up=req.params.up;
    if(isNaN(category)){
        res.status(500).send("Unauthorized request. Data is not proper");
    }
    
    if(Number.isInteger(up)){
        res.status(500).send("Unauthorized request. Data is not proper");
    }
    let sql="select p.* from product p,product_category c where c.category_id="+category+" and c.product_id=p.product_id limit "+up+","+limit;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            let products=new Array();
            products=result;
            if(products.length>0){
                let response=new Array();
            let sql="select * from product_variants where parent=1 and product_id in(";
            for(let i=0;i<products.length;i++){
                if(i==0){
                    sql+=products[i].product_id;
                } else {
                    sql+=","+products[i].product_id;
                }
            }
            sql+=")";
            con.query(sql,(err,productsData)=>{
                if(err){
                    console.log(err);
                } else {
                    response.push(products);
                    response.push(productsData);
                    res.json(response);
                }
            })
            } else {
                res.json(result);
            }
        }
    })
})

router.get('/countByCategory/:id',(req,res)=>{
    let category=req.params.id;
    let sql="select count(product_id) as countp from product_category where category_id="+category;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/department',(req,res)=>{
    let sql="select * from department";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/getProductByName/:name/:up',(req,res)=>{
    let productName=req.params.name;
    let up=req.params.up;

    if(productName==""){
        res.status(500).send("No data Found ");
    }
    if(isNaN(up)){
        res.status(500).send("Unauthorized request. Data is not Proper");
    }
    let sql="select * from product_variants where name like '%"+productName+"%' limit "+up+","+limit;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            if(result.length>0){
                let sql="select * from product where product_id in (";
                for(let i=0;i<result.length;i++){
                    if(i==0){
                        sql=sql+result[i].product_id;
                    } else {
                        sql=sql+","+result[i].product_id;
                    }
                }
                sql=sql+")";
                con.query(sql,(err,products)=>{
                    if(err){
                        console.log(err);
                    } else {
                        let response=new Array();
                        response.push(result);
                        response.push(products);
                        res.json(response);
                    }
                })
            } else {
                res.json(result);
            }
            
        }
    })
})

router.get('/countProductByName/:productName',(req,res)=>{
    let productName=req.params.productName;
    if(productName==""){
        res.status(500).send("No data found");
    }
    let sql="select count(*) as countp from product_variants where name like '%"+productName+"%'";
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})

router.get('/getProductByIds/:productIds',(req,res)=>{
    let products=req.params.productIds;
    let sql="select * from  product_variants where variant_id in "+products;
    con.query(sql,(err,result)=>{
        if(err){
            console.log(err);
        } else {
            res.json(result);
        }
    })
})
module.exports=router