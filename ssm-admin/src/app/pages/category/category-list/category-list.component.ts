import { Component, OnInit } from '@angular/core';
import { CategoryService } from 'src/app/core/mock/category.service';
import { injectChangeDetectorRef } from '@angular/core/src/render3/view_engine_compatibility';
import { AuthService } from 'src/app/core/mock/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-category-list',
  templateUrl: './category-list.component.html',
  styleUrls: ['./category-list.component.css']
})
export class CategoryListComponent implements OnInit {

  constructor(private _categoryService:CategoryService,
              private _authService:AuthService,
              private _router:Router) { }

  
  categories=new Array();
  totalCategory;
  categoryAdd={
    category_id:0,
    name:"",
    description:"",
    department_id:0
  };
  sortKey=0;
  btnStatus=0;
  selectAllStatus=0;
  selectedCategory=new Array();
  displayLimit=10;
  departments=new Array();
  currentPage=1;
  lastPage;
  sorting=0;
  search="";
  lastsearch="";
  searchFilterChecker=0;
  displayPages=new Array();
  departmentErrorText="";
  selectedDepartment={
    department_id:0,
    name:"Select the Department",
    description:""
  }
  filterDepartment={
    department_id:0,
    name:"Select the Department",
    description:""
  }

  ngOnInit() {

    // if user not logged in,it will redirect to login

    if(!this._authService.loggedIn()){
      this._router.navigate(['']);
    }

    // Count total categories added by user

    this._categoryService.countCategories()
    .subscribe(
      res=>{
        this.totalCategory=res[0].countCategory;
        let totalPages=this.totalCategory/this.displayLimit;
        this.setPagination(totalPages);
      }
    )

    // Get the categories for first page

    this._categoryService.getAllCategory(0)
    .subscribe(
      res=>{
        // @ts-ignore
        this.categories=res;
        this.setSelection();
        this._categoryService.getDepartments()
        .subscribe(
          res=>{
            // @ts-ignore
            this.departments=res;
          }
        )
      }
    );
  }

  // Set the Multiple selected categories

  setSelection(){
    delete this.selectedCategory;
    this.selectedCategory=new Array();
    for(let i=0;i<this.categories.length;i++){
      this.selectedCategory.push({"category_id":this.categories[i].category_id,"selected":0});
    }
  }

  // Display the selected department from drop-down

  selectDepartment(department){
    this.selectedDepartment=department;
    if(this.selectedDepartment.department_id!=0){
      this.departmentErrorText="";
    } 
  }

  // Calculate the page index displaying according to current page

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

  // Get categories from database of particular page

  changePage(pageno){
    this.sorting=0;
    this.sortKey=0;
    this.currentPage=pageno;
    if(this.searchFilterChecker==0){
      this._categoryService.getAllCategory((pageno*10)-10)
      .subscribe(
        res=>{
          // @ts-ignore
          this.categories=res;
          this.selectAllStatus=0;
          this.setSelection();  
        }
      )
    } else {
      this.findSearchedCategory(pageno);
    }
  }

  /* add Category to database */

  addCategory(){
    if(this.selectedDepartment.department_id==0)
    {
      this.departmentErrorText="Select the appropriate department";
    } else {
      if(this.categoryAdd.name.length>2){
        this.categoryAdd.department_id=this.selectedDepartment.department_id;
        this._categoryService.addCategory(this.categoryAdd)
        .subscribe(
          res=>{
            window.alert("Category added successfully");
          }
        )
      } else {
        window.alert("Enter category name of minimum two characters");
      }
    }
  }

  /* Update Category to database */

  updateCategory(){
    if(this.selectedDepartment.department_id==0)
    {
      this.departmentErrorText="Select the appropriate department";
    } else {
      if(this.categoryAdd.name.length>2){
        this.categoryAdd.department_id=this.selectedDepartment.department_id;
        this._categoryService.updateCategory(this.categoryAdd)
        .subscribe(
          res=>{
            window.alert("Category updated successfully");
          }
        )
      } else {
        window.alert("Enter category name of minimum two characters");
      }
    }
  }

  /* cancel the add category */

  cancelCategory(){
    this.categoryAdd.name="";
    this.categoryAdd.description="";
    this.btnStatus=0;
  }

  /* Edit the category */

  editCategory(category){
    this.categoryAdd.category_id=category.category_id;
    this.categoryAdd.name=category.name;
    this.categoryAdd.description=category.description;
    this.selectedDepartment=this.departments.find(department=>department.department_id==category.department_id);
    this.btnStatus=1;
  }

  /* Delete the category */

  deleteCategory(category){
    if(confirm("Are you sure to delete category - "+category.name)){
      this._categoryService.deleteCategory(category)
      .subscribe(
        res=>{
          // @ts-ignore
          window.alert(res.message);
        }
      )
    }
  }

  /* Change category active field to database */

  changeStatus(category,event){
    if(event.target.checked){
      category.active=1;
      this._categoryService.activateCategory(category)
      .subscribe(
      )
    } else {
      category.active=0;
      this._categoryService.activateCategory(category)
      .subscribe(
      )
    }
  }

  /* Select All Category */

  selectAll(event){
    let status;
    if(event.target.checked){
      status=1;
      this.selectAllStatus=1;
    } else {
      status=0;
      this.selectAllStatus=0;
    }
    for(let i=0;i<this.categories.length;i++){
      this.selectedCategory[i].selected=status;
    }
  }

  // change the status of selection of category when user click the checkbox

  changeSelection(index,event){
    if(event.target.checked){
      this.selectedCategory[index].selected=1;
    } else {
      this.selectedCategory[index].selected=0;
    }
  }

  // Change the active status of multiple categories

  setActivation(status){
    let category=this.selectedCategory.filter(item=>item.selected===1);
    if(category.length>0){
      let request={
        "category":category,
        "status":status
      }
      this._categoryService.changeAllCategoryStatus(request)
        .subscribe(
          res=>{
            // @ts-ignore
            window.alert(res.message);
            let j=0;
            for(let i=0;i<this.categories.length;i++){
              if(this.categories[i].category_id===category[j].category_id){
                this.categories[i].active=status;
                j++;
              }
              this.selectedCategory[i].selected=0;
            }
            this.selectAllStatus=0;
          }
        )
    } else {
      window.alert("Please select the category");
    } 
  }

  deleteAllCategory(){
    
  }

  /* Sort Data of table accoriding to various aspects */

  sortData(key){
    switch(key){
      case "id":{
        this.sortKey=1;
        if(this.sorting===0 || this.sorting===1){
          this.categories=this.categories.sort((first,second)=>first.category_id-second.category_id);
          this.sorting=11;
        } else {
          this.categories=this.categories.sort((first,second)=>second.category_id-first.category_id);
          this.sorting=1;
        }
        break;
      }

      case "name":{
        this.sortKey=2;
        if(this.sorting===0 || this.sorting===1){
          this.categories=this.categories.sort((first,second)=>(first.name>second.name?-1:1));
          this.sorting=11;
        } else {
          this.categories=this.categories.sort((first,second)=>(first.name>second.name?1:-1));
          this.sorting=1;
        }
        break;
      }

      default:{
        this.sortKey=3;
        if(this.sorting===0 || this.sorting===1){
          this.categories=this.categories.sort((first,second)=>(first.dname>second.dname?-1:1));
          this.sorting=11;
        } else {
          this.categories=this.categories.sort((first,second)=>(first.dname>second.dname?1:-1));
          this.sorting=1;
        }
        break;
      }
    }
  }

  searchCategory(){
    if(this.search!=""){
      this.lastsearch=this.search;
      this.searchFilterChecker=1;
      this.findSearchedCategory(1);
    }
  }

  findSearchedCategory(pageno){
    let totalPages;
    this.currentPage=pageno;
    let up=(pageno*10)-10;
    if(this.searchFilterChecker==11){
      let data={
        department_id:this.filterDepartment.department_id,
        up:up
      }
      this._categoryService.getCategoryByDepartmentId(data)
      .subscribe(
        res=>{
          this.categories=res[0];
          this.totalCategory=res[1];
          this.totalCategory=this.totalCategory[0].countCategory;
          totalPages=this.totalCategory/this.displayLimit;
          this.setPagination(totalPages);
          this.setSelection();
        }
      )
    } else {
      if(this.lastsearch!=this.search){
        this.searchCategory();
      } else {
        let data={
          key:this.search,
          up:up
        }
        
        this._categoryService.searchCategory(data)
        .subscribe(
          res=>{
            this.categories=res[0];
            this.totalCategory=res[1];
            this.totalCategory=this.totalCategory[0].countCategory;
            totalPages=this.totalCategory/this.displayLimit;
            this.setPagination(totalPages);
            this.setSelection();
          }
        )
      }
    }
    
    
  }

  filterDepartments(department){
    this.filterDepartment=department;
    this.searchFilterChecker=11;
    this.findSearchedCategory(1);
  }
}
