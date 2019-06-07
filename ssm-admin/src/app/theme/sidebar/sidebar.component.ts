import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.css']
})
export class SidebarComponent implements OnInit {

  main_route="dashboard"
  constructor(private _router:Router) { }

  ngOnInit() {
  }

  onClick(link){
    this._router.navigate([this.main_route+"/"+link]);
  }
}
