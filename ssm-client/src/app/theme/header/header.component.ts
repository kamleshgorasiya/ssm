import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { Router } from '@angular/router';
import { User } from 'src/app/core/data/user';
import { userInfo } from 'os';
import { UseExistingWebDriver } from 'protractor/built/driverProviders';
import { CategoryService } from 'src/app/core/mock/category.service';
import { Category } from 'src/app/core/data/category';
import { Department } from 'src/app/core/data/department';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})
export class HeaderComponent implements OnInit {

  dummyUser:User=new User();
  user="Profile";
  loginData="Login";
  cartItemsCount="";
  search="";
  wishlistItemsCount="";
  department:Department[]=new Array();
  categories:Category[]=new Array();
  category:Category[]=new Array();
  cat1:Category[]=new Array();
  cat2:Category[]=new Array();
  cat3:Category[]=new Array();

  constructor(private _authService:AuthService,
              private dataExchangeService:DataExchangeService,
              private _router:Router,
              private _categoryService:CategoryService,
              private _dataExchageService:DataExchangeService) { }
  

  ngOnInit() {
    if(this._authService.loggedIn()){
      this._authService.getUser()
      .subscribe(
        res=>{
          if(res.length>0){
            this.dataExchangeService.changeUserName(res[0]);
          }
          
        }
      )
    }
    this.dataExchangeService.userMessage$
      .subscribe(
        message=>{
          this.user=message.name;
          if(this.user!="Profile"){
            this.countCartItem();
            this.countWishlistItem();
            this.loginData="Logout"
          } else {
            this.user="Profile";
            this.loginData="Login";
            this.cartItemsCount="";
            this.wishlistItemsCount="";
          }
        }
      )

    this.dataExchangeService.addCartMessage$
    .subscribe(
      message=>{
        if(message=="added"){
          if(this._authService.loggedIn()){
            this.countCartItem();
          } else {
            this.countCartFromLocal()
          }
          
        }
      }
    )
    if(this._authService.loggedIn()){
      this.countCartItem();
    } else {
      this.countCartFromLocal();
    }
    
    this.dataExchangeService.addWishlistMessage$
    .subscribe(
      message=>{
        if(message=="added"){
          this.countWishlistItem();
        }
      }
    )
    if(this._authService.loggedIn()){
      this.countWishlistItem();
    }
    
    this._categoryService.getDepartment()
    .subscribe(
      res=>{
        this.department=res;
      },
      err=>{
        console.log(err)
      }

    )
    this._categoryService.getCategory()
    .subscribe(
      res=>{
        this.categories=res;
      }
    )

  }

  loginClick(){
    if(this.loginData=='Login'){
      this._router.navigate(['login']);
    } else {
      this.dummyUser.name="Profile";
      this.dummyUser.customer_id=0;
      this.dataExchangeService.changeUserName(this.dummyUser);
      localStorage.removeItem("token");
      this._router.navigate(['']);
    }
  }

  countCartItem(){
    this._authService.getCartData()
    .subscribe(
      res=>{
        if(res[0].cartItem>0){
          this.cartItemsCount=res[0].cartItem;
        }
      }
    );
  }

  countCartFromLocal(){
    let cartData=new Array();
    cartData=JSON.parse(localStorage.getItem("cart"));
    if(cartData!=null){
      this.cartItemsCount=cartData.length.toString();
    }
  }

  countWishlistItem(){
    this._authService.getWishlistData()
    .subscribe(
      res=>{
        if(res[0].wishlistItem>0){
          this.wishlistItemsCount=res[0].wishlistItem;
        }
      }
    )
  }
  changeDepartment(departmentID){
    delete this.cat1;
    delete this.cat2;
    delete this.cat3;
    this.cat1=new Array();
    this.cat2=new Array();
    this.cat3=new Array();
    console.log(departmentID)
    let j=0;
    let k=0;
    this.category=this.categories.filter(cat=>cat.department_id==departmentID);
    console.log(this.category)
    for(let i=0;i<30;i++){
      if(i<10){
        
        if(i>=this.category.length){
          this.cat1[i].name=" ";
        } else {
          this.cat1[i]=this.category[i];
        }
      } else{
        if(i<20){
          
          if(i>=this.category.length){
            this.cat2[j].name=" ";
            
          } else {
            this.cat2[j]=this.category[i];
          }
          j++;
        } else {
          
          if(i>=this.category.length){
            this.cat3[k].name=" ";
          } else {
            this.cat3[k]=this.category[i];
          }
          k++;
        }
      }
    }
  }

  setCategory(catname){
      let categoryId=this.categories.find(function(element){
        return element.name==catname;
      })
      this._router.navigate(['']);
      this.dataExchangeService.changeCategory(categoryId.category_id);
      
  }
  onSubmit(){
    this._dataExchageService.changeSearchData(this.search);
  }
}
