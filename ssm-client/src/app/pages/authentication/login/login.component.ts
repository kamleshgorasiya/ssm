import { Component, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { Cart } from 'src/app/core/data/cart';
import { ProductService } from 'src/app/core/mock/product.service';
import { CartService } from 'src/app/core/mock/cart.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  errorText="";
  user:any={};

  constructor(private route:ActivatedRoute,
              private _authService:AuthService,
              private _router:Router,
              private dataService:DataExchangeService,
              private _productService:ProductService,
              private _cartService:CartService) { 
  }

  ngOnInit() {
  }

  // Log in the user and store the JWT in localstorage.

  loginUser(){
    this._authService.loginUser(this.user)
    .subscribe(
      res=>{
        localStorage.setItem("token",res.token);
        this._authService.getUser()
        .subscribe(
          res=>{
             this.dataService.changeUserName(res[0])
             this.addCartData();
             let data=localStorage.getItem("reference");
             if(data=="cart"){
              
               this._router.navigate(["cart"]);
               localStorage.removeItem("reference");
             } else {
              if(data=="wishlist"){
                this._router.navigate(["wishlist"]);
                localStorage.removeItem("reference");
              } else {
               this._router.navigate(['']);
              }
             }
          },
        )
      },
      err=>{
        this.errorText=err.error.message;
      }
    )
  }

  // If user succesfully loged in, it will store the localstorage cart data into database.

  addCartData(){
    let data=localStorage.getItem("cart");
    try{
      let cart:Cart[];
      cart=JSON.parse(data);
      this._cartService.addLocalBags(cart)
      .subscribe(
        res=>{
          localStorage.removeItem("cart");
          this.dataService.changeCartData("added");
        }
      )
    } catch(e){
    }
  }

  // Go to reset password if email is filled

  resetPassword(){
    let regex=new RegExp('.+@.+\..+');
    let test=regex.test(this.user.email);
    if(test===true){
      
    } else {
      alert("Enter valid email");
    }
    //this._router.navigate(['reset-password']);
  }
}
