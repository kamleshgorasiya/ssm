import { Component, OnInit } from '@angular/core';
import { ProductService } from 'src/app/core/mock/product.service';
import { AttributeValueService } from 'src/app/core/mock/attribute-value.service';
import { CategoryService } from 'src/app/core/mock/category.service';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from 'src/app/core/mock/auth.service';
import { Variant } from 'src/app/core/data/variant';
import { AttributeValue } from 'src/app/core/data/attribute-value';
import { empty } from 'rxjs';

@Component({
  selector: 'app-add-product',
  templateUrl: './add-product.component.html',
  styleUrls: ['./add-product.component.css']
})
export class AddProductComponent implements OnInit {

  departments=new Array();
  product_id=0;
  categories=new Array();
  sizes:AttributeValue[]=new Array();
  colors:AttributeValue[]=new Array();
  selectedVariant=new Variant();
  department;
  category;
  size;
  color;
  products={
    product_id:0,
    description:"",
    display:0,
    specifications:"",
    user_id:0,
    category_id:0,
    department_id:0
  };
  variants=new Array();
  selectedDepartment={
    department_id:0,
    name:""
  }
  filterCategory={
    category_id:0,
    name:"Select Category",
    department_id:0
  };
  selectedSize={
    attribute_value_id:0,
    attribute_id:0,
    value:"Select Size"
  };
  selectedColor={
    attribute_value_id:0,
    attribute_id:0,
    value:"Select Color"
  }


  constructor(private _productService:ProductService,
              private _attributeValueService:AttributeValueService,
              private _categoryService:CategoryService,
              private _router:Router,
              private _authService:AuthService,
              private _route:ActivatedRoute) { }

  ngOnInit() {
    // Getting the component is used for which perspective
 
    this._route.url.subscribe(
      paths=>{
        if(paths[0].path=="add-product"){
          this.product_id=0;
        } else {
          this._route.params.subscribe(
            params=>{
              this.product_id=params.id;
            }
          )
        }
      }
    )

    // If user is not logged on ,it will redirect to login page

    if(!this._authService.loggedIn()){
      this._router.navigate(['']);
    }

    this.getAllValues();

    
  }

  getAllValues(){
    // Getting all necessary values

    this._categoryService.getDepartments()
    .subscribe(
      res=>{
        //@ts-ignore
        this.departments=res;
        this._productService.getValuesForAddProduct()
        .subscribe(
          res=>{
            this.sizes=res[1];
            this.colors=res[2];
            if(this.product_id>0){
              this.getProducts();
            }
          }
        )
      }
    )
  }

  getProducts(){
    this._productService.getVarinats(this.product_id)
    .subscribe(
      res=>{
        let p=res[0];
        this.products.product_id=p[0].product_id;
        this.products.description=p[0].description;
        this.products.display=p[0].display;
        this.products.specifications=p[0].specifications;
        this.products.user_id=p[0].user_id;
        this.products.category_id=p[0].category_id;
        this.products.department_id=p[0].department_id;
        this._categoryService.getCategoriesOfDepartment(p[0].department_id)
        .subscribe(
          res=>{
            //@ts-ignore
            this.categories=res;
            this.filterCategory=this.categories.find(item=>item.category_id==this.products.category_id);
            this.category=this.filterCategory.name;
          }
        )
        
        this.selectedDepartment=this.departments.find(item=>item.department_id==this.products.department_id);
        this.department=this.selectedDepartment.name;
        let variant=res[1];
        this.setVariants(variant);
      }
    )
  }

  setVariants(productVariant){
   // console.log(productVariant);
      let variant=new Variant();
      let size=new AttributeValue();
      let color=new AttributeValue();
      for(let i=0;i<productVariant.length;i++){
        variant=new Variant();
        variant.variant_id=productVariant[i].variant_id;
        variant.name=productVariant[i].name;
        variant.price=productVariant[i].price;
        variant.discount=productVariant[i].discounted_price;
        variant.quantity=productVariant[i].quantity;
        variant.color_id=productVariant[i].color_id;
        variant.size_id=productVariant[i].size_id;
        variant.isActive=productVariant[i].parent;
        variant.thumbnail=productVariant[i].thumbnail;
        variant.list_image=productVariant[i].list_image;
        variant.view_image=productVariant[i].view_image;
        variant.large_image=productVariant[i].large_image;
        size=this.sizes.find(item=>item.attribute_value_id==variant.size_id);
       
        variant.size=size.value;
        color=this.colors.find(item=>item.attribute_value_id==variant.color_id);
       
        variant.color=color.value;
        this.variants.push(variant);
      }
     // console.log(this.variants)
  }

  selectCategory(category){
    this.filterCategory=this.categories.find(item=>item.name==category);
    if(this.filterCategory){
      document.getElementById("category").style.border="1px solid #a9a9a9";
    } else {
      document.getElementById("category").style.border="1px solid #e33545";
    }
    
  }
  selectSize(size){
    this.selectedSize=this.sizes.find(item=>item.value==size);
    document.getElementById("size").style.border="1px solid #a9a9a9";
  }
  selectColor(color){
    this.selectedColor=this.colors.find(item=>item.value==color);
    document.getElementById("color").style.border="1px solid #a9a9a9";
  }

  selectDepartment(department){
    this.selectedDepartment=this.departments.find(item=>item.name==department);
    if(this.selectedDepartment){
      this._categoryService.getCategoriesOfDepartment(this.selectedDepartment.department_id)
      .subscribe(
        res=>{
          //@ts-ignore
          this.categories=res;
        }
      )
      document.getElementById("department").style.border="1px solid #a9a9a9";
    } else {
      document.getElementById("department").style.border="1px solid #e33545";
    }
    
  }

  editVariant(variant){
    this.selectedVariant=variant;
    this.selectedVariant.product_id=this.product_id;
    this.selectedColor=this.colors.find(item=>item.attribute_value_id==variant.color_id);
    this.selectedSize=this.sizes.find(item=>item.attribute_value_id==variant.size_id);
    this.color=this.selectedColor.value;
    this.size=this.selectedSize.value;
  }

  addSize(){
    let size=window.prompt("Add new size :-");
    if(size!=""){
      if(this.sizes.find(item=>item.value.toUpperCase()==size.toUpperCase())){
        window.alert("This size already exist");
      } else {  
        if(!size.replace(/\s/g,'').length){
          window.alert("Enter size properly");
        } else {
          let attribute={
            attribute_id:this.sizes[0].attribute_id,
            value:size
          }
          this._attributeValueService.addAttribute(attribute)
          .subscribe(
            res=>{
              this.getAllValues();
            }
          )
        }
      }
    }
  }

  addColor(){
    let color=window.prompt("Add new color :-");
    if(color!=""){
      if(this.colors.find(item=>item.value.toUpperCase()==color.toUpperCase())){
        window.alert("This color is already exist");
      } else {
        if(!color.replace(/\s/g,'').length){
          window.alert("Enter color properly");
        } else {
          let attribute={
            attribute_id:this.colors[0].attribute_id,
            value:color
          }
          this._attributeValueService.addAttribute(attribute)
          .subscribe(
            res=>{
              this.getAllValues();
            }
          );
        }
      }
    }
  }

  addVariant(){
    let test=0;
    if(this.selectedVariant.name==null){
      document.getElementById("name").style.border="1px solid #e33545";
      test=1;
    }
    if(this.selectedVariant.price==null){
      document.getElementById("price").style.border="1px solid #e33545";
      test=1;
    }
    if(this.selectedVariant.quantity==null){
      document.getElementById("quantity").style.border="1px solid #e33545";
      test=1;
    }
    if(this.selectedColor==null || this.selectedColor.attribute_value_id==0){
      document.getElementById("color").style.border="1px solid #e33545";
      test=1;
    }
    if(this.selectedSize==null || this.selectedSize.attribute_value_id==0){
      document.getElementById("size").style.border="1px solid #e33545";
      test=1;
    }
    if(test==0){
      this.selectedVariant.size_id=this.selectedSize.attribute_value_id;
      this.selectedVariant.color_id=this.selectedColor.attribute_value_id;
      if(!this.selectedVariant.isActive){
        this.selectedVariant.isActive=0;
      }
      if(this.selectedVariant.variant_id>0){
        this._productService.updateVariant(this.selectedVariant)
        .subscribe(
          res=>{
            delete this.variants;
            this.variants=new Array();
            this.setVariants(res[1]);
            this.selectedVariant=new Variant();
          }
        )
        console.log(this.selectedVariant);

      } else {
        this.selectedVariant.variant_id=this.product_id;
        if(!this.selectedVariant.discount){
          this.selectedVariant.discount=0;
        }
        this.selectedVariant.color=this.color;
        this.selectedVariant.size=this.size;
        this._productService.addVariant(this.selectedVariant)
        .subscribe(
          res=>{
            delete this.variants;
            this.variants=new Array();
            this.setVariants(res[1]);
            this.selectedVariant=new Variant();
          }
        ) 
      }
        
      
    } else {
      window.alert("Fill details properly");
    }
  }

  addProduct(){
    if(this.filterCategory){
      if(this.product_id>0){
        this.products.category_id=this.filterCategory.category_id;
        this._productService.updateProduct(this.products)
        .subscribe(
          res=>{}
        )
      } else {
        this.products.category_id=this.filterCategory.category_id;
        this.products.specifications='{"Size":{},"Color":{}}';
        this._productService.addProduct(this.products)
        .subscribe(
          res=>{
  
            //@ts-ignore
            this.product_id=res.product_id;
            //@ts-ignore
            if(res.success==true){
              window.alert("Product added successfully");
            }
          },
          err=>{
            window.alert("Add detail properly");
          }
        );
      }
      
    } else {
      window.alert("Enter detail properly");
    }
    
  }

  changeName(){
    if(this.selectedVariant.name!=null){
      document.getElementById("vname").style.border="1px solid #a9a9a9";
    } else {
      document.getElementById("vname").style.border="1px solid #e33545";
    }
  }
  changePrice(){
    if(this.selectedVariant.price!=null){
      document.getElementById("price").style.border="1px solid #a9a9a9";
    } else {
      document.getElementById("price").style.border="1px solid #e33545";
    }
  }
  changeQuantity(){
    if(this.selectedVariant.quantity!=null){
      document.getElementById("quantity").style.border="1px solid #a9a9a9";
    } else {
      document.getElementById("quantity").style.border="1px solid #e33545";
    }
  }
  changeisActive(){
    if(this.selectedVariant.isActive===1){
      this.selectedVariant.isActive=0;
    } else {
      this.selectedVariant.isActive=1;
    }
  }

  cancelVariant(){
    this.selectedVariant=new Variant();
    this.color="";
    this.size="";
  }

  cancelProduct(){
    this.product_id=0;
    this.products.description="";
    this.category="";
    this.department="";
  }

  addImage(variant){
    localStorage.setItem("variant",JSON.stringify(variant));
    this._router.navigate(['dashboard/add-image/'+variant.variant_id]);
  }
}
