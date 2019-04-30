import { Component, OnInit } from '@angular/core';
import { CartService } from 'src/app/core/mock/cart.service';
import { Router } from '@angular/router';
import { Product } from 'src/app/core/data/product';
import { AuthService } from 'src/app/core/mock/auth.service';

@Component({
  selector: 'app-wishlist',
  templateUrl: './wishlist.component.html',
  styleUrls: ['./wishlist.component.css']
})
export class WishlistComponent implements OnInit {

  wishlist;
  products:Product[];
  count;

  constructor(private cartService:CartService,
              private _router:Router,
              private _authService:AuthService) { }
  
  ngOnInit() {
    if(!this._authService.loggedIn()){
      this._router.navigate(['']);
    }
    this.cartService.getWishlistProduct()
    .subscribe(
      res=>{
        this.wishlist=res[0];
        this.products=res[1];
        this.count=this.products.length;
        if(this.count<6){
          let p=new Product();
          p.product_id=0;
          let pm=6-this.count;
          for(let i=0;i<pm;i++){
            this.products.push(p);
          }
        }
      }
    )
  }
  addToBag(productId){
    this._router.navigate(['/product',productId])
  }
  removeItem(productId){
    let product={product_id:productId};
    this.cartService.removeWishlist(product)
    .subscribe(
      res=>{
        this.products=this.products.filter(item=>item.product_id!==productId)
      }
    )
  }
}
