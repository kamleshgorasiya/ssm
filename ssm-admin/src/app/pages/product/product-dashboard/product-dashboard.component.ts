import { Component, OnInit } from '@angular/core';
import { ProductService } from 'src/app/core/mock/product.service';
import { DisplayProduct } from 'src/app/core/data/display-product';
import { CategoryService } from 'src/app/core/mock/category.service';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from 'src/app/core/mock/auth.service';

@Component({
  selector: 'app-product-dashboard',
  templateUrl: './product-dashboard.component.html',
  styleUrls: ['./product-dashboard.component.css']
})
export class ProductDashboardComponent implements OnInit {

  totalProducts={
    totalProduct:0
  };
  allProducts=new Array();
  products=new Array();
  variants=new Array();
  displayPages=new Array();
  images=new Array();
  lastPage;
  currentPage=1 ;
  totalPages;
  sorting=0;
  sortKey=0;
  search="";
  searchFilterChecker=0;
  lastSearch="";
  departments=new Array();
  filterDepartment={
    category_id:0,
    name:"Select Department",
    department_id:0
  }

  constructor(private _productService:ProductService,
              private _categoryService:CategoryService,
              private _router:Router,
              private _authService:AuthService) { }

  ngOnInit() {

    // if user not logged in,it will redirect to login page

    if(!this._authService.loggedIn()){
      this._router.navigate(['']);
    }
      
      this.getAllProducts();
      // Get categories for filter purpose

      this._categoryService.getDepartments()
      .subscribe(
        res=>{
          // @ts-ignore
          this.departments=res;
        }
      );
  }

  addProduct(){
    this._router.navigate(['dashboard/add-product']);
  }

  getAllProducts(){

    this.search="";
    this.filterDepartment.department_id=0;
    this.searchFilterChecker=0;

    // Count total product of user for pagination purpose 

    this._productService.countAllProduct()
    .subscribe(
      res=>{
        this.totalProducts=res[0];
        let totalPages=this.totalProducts.totalProduct/10;
        this.totalPages=Math.ceil(totalPages);
        this.setPagination(totalPages);
      }
    )

    // Get all products for first page 

    this._productService.getAllProduct(0)
    .subscribe(
      res=>{
        this.products=res[0];
        this.variants=res[1];
        this.setAllProducts();
        
      }
    );
  }

  // Set All Products for displaying the user

  setAllProducts(){
    delete this.allProducts;
    delete this.images;
    this.images=new Array();
    this.allProducts=new Array();
    let product=new DisplayProduct();
    let img;
    
    for(let i=0;i<this.products.length;i++){
      let variant=this.variants.find(item=>item.product_id===this.products[i].product_id);
      if(variant){
        if(variant.thumbnail){
          img=JSON.parse(variant.thumbnail);
        } else {
          img=new Array();
          img.push("");
        }
        
        product={
          product_id:this.products[i].product_id,
          variant_id:variant.variant_id,
          name:variant.name,
          price:variant.price,
          quantity:variant.quantity,
          description:this.products[i].description,
          category_id:this.products[i].category_id,
          category_name:this.products[i].cname,
          thumbnail:img[0]
        }
      } else {
        product={
          product_id:this.products[i].product_id,
          variant_id:0,
          name:"Add a variants",
          price:0,
          quantity:0,
          description:this.products[i].description,
          category_id:this.products[i].category_id,
          category_name:this.products[i].cname,
          thumbnail:"ds"
      }
      }
      
      this.allProducts.push(product);
    }
  }

  // Set page navigation detail 

  setPagination(totalPages){
    delete this.displayPages;
    this.displayPages=new Array();
    
    totalPages=Math.ceil(totalPages);
    this.lastPage=totalPages;
    let startPage;
    
    if(this.currentPage>5 && this.currentPage<this.lastPage-5){
      startPage=this.currentPage-5;
      for(let i=0;i<this.currentPage+5;i++){
        this.displayPages.push(startPage);
        startPage=startPage+1;
      }
    } else {
      if(this.currentPage<5){
        for(let i=0;i<10;i++){
          this.displayPages.push(i+1);
          if(i+1==this.lastPage){
            break;
          }
        }
      } else {
        for(let i=this.lastPage-10;i<=this.lastPage;i++){
          if(i>0){
            this.displayPages.push(i);
          }
        }
      }
    }
  }

  // Get products from server when user change the page 

  changePage(pageno){
    this.currentPage=pageno;
    this.setPagination(this.totalPages)
    if(this.searchFilterChecker==1){
      this.getSearchedProduct(pageno);
    } else {
      if(this.searchFilterChecker==11){
        this.getFilteredProducts(pageno);
      } else {
        this._productService.getAllProduct((pageno*10)-10)
        .subscribe(
          res=>{
            this.products=res[0];
            this.variants=res[1];
            this.setAllProducts();
          }
        )
      }
    }
  }

  // Filter the products by department

  filterDepartments(department){
    this.currentPage=1;
    this.filterDepartment=department;
    this.searchFilterChecker=11;
    this.getFilteredProducts(1);
  }

  // Get filtered products 

  getFilteredProducts(pageno){
    let up=(pageno*10)-10;
    this._productService.getProductsByDepartment(up,this.filterDepartment.department_id)
    .subscribe(
      res=>{
        this.products=res[0];
        this.variants=res[1];
        this._productService.countProductsByDepartment(this.filterDepartment.department_id)
        .subscribe(
          res=>{
            this.totalProducts=res[0];
            let totalPages=this.totalProducts.totalProduct/10;
            this.setPagination(totalPages);
            this.totalPages=Math.ceil(totalPages);
            this.setAllProducts();
          }
        )
      }
    );
  }

  // Search products by user given keywords

  searchProduct(){
    if(this.search!=""){
      this.currentPage=1;
      this.searchFilterChecker=1;
      this.getSearchedProduct(1);
    }
  }

  // Getting searched products from database

  getSearchedProduct(pageno){
    if(this.lastSearch!==this.search){
      pageno=1;
      this.currentPage=1;
    }
    let up=(pageno*10)-10;
    this._productService.searchProducts(this.search,up)
    .subscribe(
      res=>{
        
        this.totalProducts=res[0];
        this.totalProducts=this.totalProducts[0];
        if(this.totalProducts.totalProduct>0){
          this.variants=res[1];
          this.products=res[2];
          let totalPages=this.totalProducts.totalProduct/10;
          this.setPagination(totalPages);
          this.totalPages=Math.ceil(totalPages);
          this.setAllProducts();
        }
      }
    )
    this.lastSearch=this.search;
  }

  // Sort the data displayed on view by key which is selected by user

  sortData(key){
    switch(key){
      case "id":{
        this.sortKey=1;
        if(this.sorting===0 || this.sorting===1){
          this.allProducts=this.allProducts.sort((first,second)=>first.product_id-second.product_id);
          this.sorting=11;
        } else {
          this.allProducts=this.allProducts.sort((first,second)=>second.product_id-first.product_id);
          this.sorting=1;
        }
        break;
      }
  
      case "name":{
        this.sortKey=2;
        if(this.sorting===0 || this.sorting===1){
          this.allProducts=this.allProducts.sort((first,second)=>(first.name>second.name?-1:1));
          this.sorting=11;
        } else {
          this.allProducts=this.allProducts.sort((first,second)=>(first.name>second.name?1:-1));
          this.sorting=1;
        }
        break;
      }
  
      case "price":
        this.sortKey=3;
        if(this.sorting===0 || this.sorting===1){
          this.allProducts=this.allProducts.sort((first,second)=>first.price-second.price);
          this.sorting=11;
        } else {
          this.allProducts=this.allProducts.sort((first,second)=>second.price-first.price);
          this.sorting=1;
        }
        break;

      default:{
        this.sortKey=4;
        if(this.sorting===0 || this.sorting===1){
          this.allProducts=this.allProducts.sort((first,second)=>first.quantity-second.quantity);
          this.sorting=11;
        } else {
          this.allProducts=this.allProducts.sort((first,second)=>first.quantity-second.quantity);
          this.sorting=1;
        }
        break;
      }
    }
  }

  editProduct(product){
    this._router.navigate(['dashboard/edit-product/'+product.product_id]);
  }
}
