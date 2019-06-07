import { Component, OnInit } from '@angular/core';
import { ProductService } from 'src/app/core/mock/product.service';
import { Product } from 'src/app/core/data/product';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { Router, ActivatedRoute } from '@angular/router';
import { CartService } from 'src/app/core/mock/cart.service';
import { AuthService } from 'src/app/core/mock/auth.service';

@Component({
  selector: 'app-products',
  templateUrl: './products.component.html',
  styleUrls: ['./products.component.css']
})
export class ProductsComponent implements OnInit {

  pages:number[]=new Array();
  currentPage=1;
  lastPage;
  up:number=0;
  previous;
  next;
  limit;
  bound:{
    "up":number,
    "limit":number
  };
  search="";
  products:Product[];
  size;
  count;
  color;
  wishlist=new Array();
  colors:any[]=new Array();
  sizes:any[]=new Array();
  product={
    "product_id":0,
    "attribute":"Size"
  };
  productCount;
  CategoryID;

  constructor(private productService:ProductService,
              private dataExchangeServie:DataExchangeService,
              private _router:Router,
              private _cartService:CartService,
              private _authService:AuthService,
              private _route:ActivatedRoute) { 
  }

  setPaging(){
    let totalPages=this.productCount[0].countp/this.limit;
    this.lastPage=Math.ceil(totalPages);
    delete this.pages;
    this.pages=new Array();
    if(this.currentPage>5){
      let j=this.currentPage-5;
      for(let i=0;i<10;i++){
        j++;
        if(j<=this.lastPage){
          this.pages[i]=j;
        } 
      }
    } else {
      for(let i=0;i<10;i++){
        if(i+1<=this.lastPage){
          this.pages[i]=i+1;
        } 
      }
    }
    if(this.currentPage==1){
      this.next=2;
    }
    
  }

  setBound(){
    this.limit=15;
    this.up=this.currentPage*this.limit;
    this.up=this.up-this.limit;
    this.bound={
      "up":this.up,
      "limit":this.limit
    }
  }

  getAllProduct(){
    this.search=""
    this.productService.getProducts(this.bound)
      .subscribe(
        res=>{
          this.products=res;
          this.setWishlist();
          let pm=this.products.length;
      if(pm<6)
      {
        let p=new Product();
        pm=6-this.products.length;
        for(let i=pm;i<10;i++){
          p.product_id=0;
          this.products.push(p);
        }
      }
    }
  );
      
    this.productService.countProducts()
        .subscribe(
          res=>{
            this.productCount=res;
            this.setPaging();
          }
        );
    
  }

  setWishlist(){
    delete this.wishlist;
    this.wishlist=new Array();
    if(this._authService.loggedIn()){
      this._authService.getWishlistData()
      .subscribe(
        res=>{
          if(res[0].wishlistItem>0){
            this._cartService.getWishlistProduct()
            .subscribe(
              res=>{
                let product=res[1];
                
                  let message;
                  for(let i=0;i<this.products.length;i++){
                    for(let j=0;j<product.length;j++){
                      if(this.products[i].product_id===product[j].product_id){
                        message="WISHLISTED";
                        break;
                      } else {
                        message="WISHLIST";
                      }
                    }
                    this.wishlist.push(message);
                  } 
                
              }
            )
          } else {
            for(let i=0;i<this.products.length;i++){
              this.wishlist.push("WISHLIST")
            }
          }
        }
      )
      
    }else{
      for(let i=0;i<this.products.length;i++){
        this.wishlist.push("WISHLIST")
      }
    }
    
  }

  getProductById(){
    this.search="";
    let category={
      "categoryId":this.CategoryID,
      "up":this.bound.up,
      "limit":this.bound.limit
    };
    this.productService.getProductByCategory(category)
      .subscribe(
        res=>{
           if(res.length==0){
             this.getAllProduct();
           } else {
            this.products=res;
            this.count=res[0].attributes;
            let pm=this.products.length;
          if(pm<6)
          {
            let p=new Product();
            p.product_id=0;
            pm=6-this.products.length;
            for(let i=0;i<pm;i++){
              this.products.push(p);
            }
        }
           }
        }
      )
      this.productService.countByCategory(category)
      .subscribe(
        res=>{
          this.productCount=res;
          this.setPaging();
        }
      )
      this.setWishlist();
  }
  ngOnInit() {
    this.dataExchangeServie.searchMessage$
    .subscribe(
      message=>{
        let search=message;
        if(search!=null){
          if(search==""){
            this.getAllProduct()
          } else {
            let data={"name":search};
            this.search=data.name;
            this.productService.getProductByName(data)
            .subscribe(
              res=>{
                this.products=res;
                let pm=this.products.length;
                if(pm<6)
                {
                  let p=new Product();
                  pm=6-this.products.length;
                  for(let i=pm;i<10;i++){
                    p.product_id=0;
                    this.products.push(p);
                  }
                }
              }
            )
          }
          
        } else {
          
        }
      }
    )
      
    if(this.search==""){
      this.setBound();
      this.getAllProduct();
      this.next=2;
      this.dataExchangeServie.currentmessage$
      .subscribe(
        message=>{
          this.currentPage=1;
          this.setBound();
          this.CategoryID=message;
          if(this.CategoryID!=0){
            this.getProductById()
          } else {
            this.getAllProduct();
          }
        }   
      )
    }
  }

onHover(product){

    delete this.count;
    delete this.sizes;
    this.sizes=new Array();
    this.count=this.products[product].attributes;

    this.count=JSON.parse(this.count)
    this.size=this.count.Size;

    let keys=Object.keys(this.size);
    for(let i=0;i<keys.length;i++){
      let key=keys[i];
      this.sizes[i]=this.size[key];
    }
  }

paging(pg){
  this.currentPage=pg;
  this.setBound();
  
  if(this.CategoryID!=null && this.CategoryID!=0){
    this.getProductById();

  } else {
    this.setPaging();
    this.getAllProduct();
  }
      this.previous=this.currentPage-1;
      this.next=this.currentPage+1;
}

addToBag(productId){
  this._router.navigate(['/product',productId])
}

addToWishList(productId){
  this._router.navigate(['/product',productId])
}

imageClick(productId){
  this._router.navigate(['/product',productId])
}
}