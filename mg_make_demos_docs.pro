; docformat = 'rst'

pro mg_make_demos_docs
  compile_opt strictarr

  idldoc, root='src', output='api-docs', $
          title='IDL demos', subtitle='Michael Galloy', $
          /embed, $
          format_style='rst', $
          overview='overview.txt'
end
