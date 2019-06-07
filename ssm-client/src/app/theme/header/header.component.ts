import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/core/mock/auth.service';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { Router } from '@angular/router';
import { User } from 'src/app/core/data/user';
import { CategoryService } from 'src/app/core/mock/category.service';
import { Category } from 'src/app/core/data/category';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})
export class HeaderComponent implements OnInit {

  dummyUser:User=new User();
  currentDepartment=0;
  currentCtaegory=0;
  user="Profile";
  loginData="Login";
  cartItemsCount="";
  search="";
  wishlistItemsCount="";
  hideShow=0;
  departments:any[]=new Array();
  categories:Category[]=new Array();
  category:Category[]=new Array();
  cat1:any[]=new Array();
  cat2:any[]=new Array();
  cat3:any[]=new Array();
  cats:any[]=new Array();


  constructor(private _authService:AuthService,
              private dataExchangeService:DataExchangeService,
              private _router:Router,
              private _categoryService:CategoryService,
              private _dataExchageService:DataExchangeService) { 
                
                for(let i=0;i<10;i++){
                  this.cat1.push(new Category());
                  this.cat2.push(new Category());
                  this.cat3.push(new Category());
                  this.cat1[i].name=" ";
                  this.cat2[i].name=" ";
                  this.cat3[i].name=" ";
                }
              }
  

  ngOnInit() {
    if(this._authService.loggedIn()){

      // If user is logged in, it will display user's name on header navigations

      this._authService.getUser()
      .subscribe(
        res=>{
          let response:any=res;
          if(response.length>0){
            this.dataExchangeService.changeUserName(res[0]);
            this.user=res[0].name;
          }
        }
      )
    }

    // It will capture events of login,sign up,log out for displaying the name of user on header

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

    // It will increase or decrease the cart items count

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

    // It will increase or decrease the wishlist's items count

    this.dataExchangeService.addWishlistMessage$
    .subscribe(
      message=>{
        if(message=="added"){
          this.countWishlistItem();
        }
      }
    )
    
    // It will find departments from database

    this._categoryService.getDepartment()
    .subscribe(
      res=>{
        this.departments=res;
        this._categoryService.getCategory()
        .subscribe(
          res=>{
            this.categories=res;
            this.cats[0]=this.categories.filter(cat=>cat.department_id==this.departments[0].department_id);
            this.cats[1]=this.categories.filter(cat=>cat.department_id==this.departments[1].department_id);
            this.cats[2]=this.categories.filter(cat=>cat.department_id==this.departments[2].department_id);
          }
        )
      },
      err=>{
        console.log(err)
      }
    )
    
  }

  // It will redirect to login page 

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
    this.closenav();
  }

  // It will count total items in cart of user from database

  countCartItem(){
    this._authService.getCartData()
    .subscribe(
      res=>{
        if(res[0].cartItem>0){
          this.cartItemsCount=res[0].cartItem;
        } else {
          this.cartItemsCount="";
        }
      }
    );
  }

  // It will count total items in cart in local storage

  countCartFromLocal(){
    let cartData=new Array();
    cartData=JSON.parse(localStorage.getItem("cart"));
    if(cartData!=null){
      this.cartItemsCount=cartData.length.toString();
    }
  }

  // It will count total items in wishlist of user

  countWishlistItem(){
    this._authService.getWishlistData()
    .subscribe(
      res=>{
        if(res[0].wishlistItem>0){
          this.wishlistItemsCount=res[0].wishlistItem;
        } else {
          this.wishlistItemsCount=""
        }
      }
    )
  }

  // It will change categories according to selected department

  changeDepartment(departmentID){
    let cat=new Category();
    let j=0;
    let k=0;
    this.category=this.categories.filter(cat=>cat.department_id==departmentID);

    for(let i=0;i<30;i++){
      if(i<10){
        
        if(i>=this.category.length){
          cat.name=" ";
          this.cat1[i]=cat.name;
        } else {
          this.cat1[i]=this.category[i];
          
        }
      } else{
        if(i<20){
          
          if(i>=this.category.length){
            cat.name=" ";
            this.cat2[j].name=cat.name;
            
          } else {
            this.cat2[j]=this.category[i];
          }
          j++;
        } else {
          
          if(i>=this.category.length){
            cat.name=" ";
            this.cat3[k].name=cat.name;
          } else {
            this.cat3[k]=this.category[i];
          }
          k++;
        }
      }
    }
    this.openCategory();
  }

  // It will redoirect to category's product display according to selected category

  setCategory(catname){
      let categoryId=this.categories.find(function(element){
        return element.name==catname;
      })
      this.closenav();
      this._router.navigate(['category',categoryId.category_id,catname]);
      this.currentCtaegory=categoryId.category_id;
      this.currentDepartment=categoryId.department_id;
      
  }

  // It will redirect to seraching page when user search 

  onSubmit(){
    if(this.search!=""){
      this._dataExchageService.changeSearchData(this.search);
      this._router.navigate(['search',this.search]);
    } else {
      console.log("Enter the value to search")
    }
    
  }

  // It will open sidebar displaying categories and departments when screen size is small

  opensidebar(){
    if(this.hideShow==0){
      this.hideShow=1;
      this.opennav();
    } else {
      this.hideShow=0;
      this.closenav();
    }
  }

  // It will open the sidebar

  opennav(){
    document.getElementById("menu").style.display="block";
    document.getElementById("myOverlay").style.display = "block";
  }
  
  // It will close the sidebar
  closenav(){
    document.getElementById("menu").style.display = "none";
    document.getElementById("myOverlay").style.display = "none";
    this.hideShow=0;
  }

  // It will decrease opacity of other content except category and header

  openCategory(){
    document.getElementById("myOverlay").style.display = "block";
  }

// It will increase opacity of other content except category and header

  closeCategory(){
    document.getElementById("myOverlay").style.display = "none";
  }
}
