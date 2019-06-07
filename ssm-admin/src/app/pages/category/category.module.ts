import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CategoryListComponent } from './category-list/category-list.component';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

@NgModule({
  declarations: [CategoryListComponent],
  imports: [
    CommonModule,
    FormsModule,
    RouterModule
  ]
})
export class CategoryModule { }
