import { Component, OnInit } from '@angular/core';
import { DataExchangeService } from 'src/app/core/mock/data-exchange.service';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-layout',
  templateUrl: './layout.component.html',
  styleUrls: ['./layout.component.css']
})
export class LayoutComponent implements OnInit {

  categoryId;
  constructor() { }

  ngOnInit() {
  }
}
