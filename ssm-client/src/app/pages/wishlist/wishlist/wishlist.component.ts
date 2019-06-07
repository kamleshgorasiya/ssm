import { Component, OnInit } from '@angular/core';
import { CartService } from 'src/app/core/mock/cart.service';
import { Router } from '@angular/router';
import { Product } from 'src/app/core/data/product';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';

@Component({
  selector: 'app-wishlist',
  templateUrl: './wishlist.component.html',
  styleUrls: ['./wishlist.component.css']
})
export class WishlistComponent implements OnInit {

  wishlist;
  products=new Array();
  count;
  images=new Array();
  login=0;

  constructor(private _cartService:CartService,
              private _router:Router,
              private _authService:AuthService,
              private _dataExchangeService:DataExchangeService) { }
  
  ngOnInit() {
    if(!this._authService.loggedIn()){
      this.login=1;
    } else {
      // Fetching the details of wishlist products.

    this._cartService.getWishlistProduct()
    .subscribe(
      res=>{
        this.wishlist=res[0];
        this.products=res[1];
        this.count=this.products.length;
        for(let i=0;i<this.count;i++){
          let img=JSON.parse(this.products[i].list_image);
          this.images[i]=img[0];
        }
      },err=> {
        this.login=1
      }
    )
    }

    
  }

  // Move the control to product detail for adding it into Bag.

  addToBag(productId){
    this._dataExchangeService.changeProduct(this.products.find(item=>item.product_id==productId));
    this._router.navigate(['/product',productId])
  }

  // Remove Item from Wishlist.

  removeItem(productId){
    let product={product_id:productId};
    this._cartService.removeWishlist(product)
    .subscribe(
      res=>{
        this.products=this.products.filter(item=>item.product_id!==productId)
        this.count=this.count-1;
      }
    )
  }

  // Set reference to localstorage for remember login request is coming from wishlist.

  goToLogin(){
    localStorage.setItem("reference","wishlist")
    this._router.navigate(['login']);
  }
}
