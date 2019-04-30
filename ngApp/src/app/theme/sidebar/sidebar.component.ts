import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { CategoryService } from 'src/app/core/mock/category.service';
import { Category } from 'src/app/core/data/category';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.css']
})
export class SidebarComponent implements OnInit {

  constructor(private categoryService:CategoryService,private dataExchageService:DataExchangeService) { }
  categories:Category[];
  ngOnInit() {
    this.categoryService.getCategory()
      .subscribe(
        res=>{
          //console.log(res);
          this.categories=res;
        },
        err=>{
          console.log(err);
        }
      )
  }

  onClick(categoryId){
    this.dataExchageService.changeCategory(categoryId);
  }

}
