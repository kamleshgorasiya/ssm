import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { ProductService } from 'src/app/core/mock/product.service';
import { CartService } from 'src/app/core/mock/cart.service';
import { AuthService } from 'src/app/core/mock/auth.service';
import { Product } from 'src/app/core/data/product';
import { ProductsComponent } from '../products/products.component';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';

@Component({
  selector: 'app-search-product',
  templateUrl: './search-product.component.html',
  styleUrls: ['./search-product.component.css']
})
export class SearchProductComponent implements OnInit {

  constructor(private _route:ActivatedRoute,
              private productService:ProductService,
              private _router:Router,
              private _cartService:CartService,
              private _authService:AuthService,
              private dataExchangeService:DataExchangeService) { }

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
  products:Product[]=new Array();
  size;
  count;
  color;
  images=new Array();
  wishlist=new Array();
  colors:any[]=new Array();
  sizes:any[]=new Array();
  product={
    "product_id":0,
    "attribute":"Size"
  };
  productCount;
  totalProduct;
  CategoryID;

  // Set paging configuration

  setPaging(){
    delete this.pages;
    this.pages=new Array();

    let totalPages=this.productCount[0].countp/this.limit;
    this.lastPage=Math.ceil(totalPages);
   
    let startPage;
    if(this.currentPage>5 && this.currentPage<this.lastPage-5){
      startPage=this.currentPage-5;
      for(let i=0;i<this.currentPage+5;i++){
        this.pages.push(startPage);
        startPage=startPage+1;
      }
    } else {
      if(this.currentPage<5){
        for(let i=0;i<10;i++){
          this.pages.push(i+1);
          if(i+1==this.lastPage){
            break;
          }
        }
      } else {
        for(let i=this.lastPage-10;i<=this.lastPage;i++){
          if(i>0){
            this.pages.push(i);
          }
          
        }
      }
    }
  }

  // Set bound or limit of displaying products in one page

  setBound(){
    this.limit=15;
    this.up=this.currentPage*this.limit;
    this.up=this.up-this.limit;
    this.bound={
      "up":this.up,
      "limit":this.limit
    }
  }

  // Prepare the product for displaying on page 

  setProducts(p1:any,p2:any){
    delete this.products;
    this.products=new Array();
    this.totalProduct=p1.length;
    let product=new Product();
    for(let i=0;i<p1.length;i++){
      let p=p2.find(item=>item.product_id==p1[i].product_id);
        product={
        product_id:p1[i].variant_id,
        name:p1[i].name,
        description:p.description,
        price:p1[i].price,
        discounted_price:p1[i].discounted_price+p1[i].price,
        image:p1[i].list_image,
        image_2:"",
        thumbnail:"",
        display:0,
        attributes:p.specifications
      };
      this.products.push(product);
    }
    this.setWishlist();
    for(let i=0;i<this.products.length;i++){
      this.products[i].image=JSON.parse(this.products[i].image);
    }
  }

  // It will checks the product is already in wishlist or not for all products in page

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

  // it will search the product from database

  searchProducts(){
    if(this.search!=null){
      if(this.search!=""){
        let data={"name":this.search,"bound":this.bound.up,"limit":this.bound.limit};
        this.search=data.name;
        this.productService.getProductByName(data)
        .subscribe(
          res=>{
            if(res.length>0){
              this.setProducts(res[0],res[1]);
              this.productService.getProductCountByName(data)
              .subscribe(
                res=>{
                  if(res.length>0){
                    this.productCount=res;
                    this.setPaging();
                  }
                }
              )
            } else {
              this.totalProduct=0;
            }
          }
        )
      }
    }
  }

  ngOnInit() {

    // get the keyword for search from url of page

    this._route.params
    .subscribe(
      message=>{
        this.search=message.search;
      }
    )
      
    // get search keyword from service and search that product 

    this.dataExchangeService.searchMessage$
    .subscribe(
      message=>{
        this._route.params
        .subscribe(
          data=>{
            this.search=data.search;
            this.searchProducts();
          }
        )
      }
    )
    this.setBound();
    this.searchProducts();
  }

  // When user hover the product it will set that products attributes

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

  // Set page configurations for pagination

  paging(pg){
    this.currentPage=pg;
    this.setBound();
    
    this.searchProducts();
        this.previous=this.currentPage-1;
        this.next=this.currentPage+1;
  }

  // When user click the add to bag or wishlist or image of product it will display products detail.

  addToBag(productId){
    let p=this.products.find(item=>item.product_id==productId);
    p.image=JSON.stringify(p.image);
  
    localStorage.setItem("product",JSON.stringify(p));
    this._router.navigate(['/product',productId])
  }

}
