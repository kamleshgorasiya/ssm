import { Component, OnInit } from '@angular/core';
import { Product } from 'src/app/core/data/product';
import { AuthService } from 'src/app/core/mock/auth.service';
import { CartService } from 'src/app/core/mock/cart.service';
import { ProductService } from 'src/app/core/mock/product.service';
import { Router, ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-category-product',
  templateUrl: './category-product.component.html',
  styleUrls: ['./category-product.component.css']
})
export class CategoryProductComponent implements OnInit {

  productCount;
  CategoryID;
  currentPage=1;
  lastPage;
  previous;
  next;
  limit;
  size;
  count;
  color;
  categoryName;
  search="";
  up:number=0;
  products:Product[]=new Array();
  pages:number[]=new Array();
  images=new Array();
  wishlist=new Array();
  colors:any[]=new Array();
  sizes:any[]=new Array();
  bound:{
    "up":number,
  };
  product={
    "product_id":0,
    "attribute":"Size"
  };

  
  constructor(private _authService:AuthService,
              private _productService:ProductService,
              private _cartService:CartService,
              private _router:Router,
              private _route:ActivatedRoute) { }

  ngOnInit() {
    this._route.params
    .subscribe(
      message=>{
        this.CategoryID=message.id;
        this.categoryName=message.name;
        this.getProductById();
      }
    )
  }


  
  // Set the values for pagination

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

  // Sets the limits and upper bound for pagination 

  setBound(){
    this.limit=15;
    this.up=this.currentPage*this.limit;
    this.up=this.up-this.limit;
    this.bound={
      "up":this.up
    }
  }

  // prepare display content for products

  setProducts(products:any,commonProducts:any){
    delete this.products;
    this.products=new Array();
    let product=new Product();
    for(let i=0;i<products.length;i++){
      let commonForVariants=commonProducts.find(item=>item.product_id==products[i].product_id);
        product={
        product_id:products[i].variant_id,
        name:products[i].name,
        description:commonForVariants.description,
        price:products[i].price,
        discounted_price:products[i].discounted_price+products[i].price,
        image:products[i].list_image,
        image_2:"",
        thumbnail:products[i].thumbnail,
        display:0,
        attributes:commonForVariants.specifications
      };
      this.products.push(product);
    }
    this.setWishlist();
    for(let i=0;i<this.products.length;i++){
      this.products[i].image=JSON.parse(this.products[i].image);
    }
  }

  // Set all product which are not wishlisted

  setAllWishlist(){
    for(let i=0;i<this.products.length;i++){
      this.wishlist.push("WISHLIST")
    }
  }

  // it will check the added to wishlist 

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
            this.setAllWishlist();
          }
        }
      )
      
    }else{
      this.setAllWishlist();
    }
  }

  // it will display products by category

  getProductById(){
    this.setBound();
    this.search="";
    let category={
      "categoryId":this.CategoryID,
      "up":this.bound.up
    };

    this._productService.getProductByCategory(category)
      .subscribe(
        res=>{
           if(res.length==0){
             this.getAllProduct();
           } else {
             let p2=res[0];
             let p1=res[1];
             this.setProducts(p1,p2);
        }
      }
      )
      this._productService.countByCategory(category)
      .subscribe(
        res=>{
          this.productCount=res;
          this.setPaging();
        }
      )
  }

   // It will fetch all products from database within limit of bounds.

   getAllProduct(){
    this._productService.getProducts(this.bound)
      .subscribe(
        res=>{
          let p1=res[0];
          let p2=res[1];
          this.setProducts(p1,p2);
      }
    );
      
    this._productService.countProducts()
    .subscribe(
      res=>{
        this.productCount=res;
        this.setPaging();
      }
    );
  }

// Set attributes of specific product when user hover the mouse on product

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

  // set the current Page No,Previous Page No.,Next Page No.

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

// Product is adding to bag

addToBag(productId){
  let p=this.products.find(item=>item.product_id==productId);
  p.image=JSON.stringify(p.image);

  localStorage.setItem("product",JSON.stringify(p));
  this._router.navigate(['/product',productId])
}

// Adding product to wishlist

addToWishList(productId){
  let p=this.products.find(item=>item.product_id==productId);
  p.image=JSON.stringify(p.image);

  localStorage.setItem("product",JSON.stringify(p));
  this._router.navigate(['/product',productId])
}

// On clicking image, Display a product description
imageClick(productId){
 
  let p=this.products.find(item=>item.product_id==productId);
  p.image=JSON.stringify(p.image);
  
  localStorage.setItem("product",JSON.stringify(p));
  this._router.navigate(['/product',productId])
}
}
